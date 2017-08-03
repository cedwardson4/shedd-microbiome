#!/bin/sh

#TaxonomyFixer.sh by Christian Edwardson
#Run this on rdp_assigned_taxonomy/XX_rep_set_tax_assignments.txt
#Usage: TaxonomyFixer.sh [tax_assignments.txt file]

#Flip so score is before taxonomy
awk '{ FS = OFS = "\t" } { print $1,$3,$2}' $1 > $1.new.txt

#1)Convert semicolons to tabs to have unified FS
#2)Remove Ambiguous_taxa since I'm treating no assignment and Ambig_taxa the same for the purpose of this script (Ambiguous_taxa is a database assignment, whereas blank is no assignment at that level)
sed -i 's/\;Ambiguous_taxa/\tAmbiguous_taxa/g' $1.new.txt 
sed -i 's/\;D_[0-9]__uncultured.*//g' $1.new.txt 
sed -i 's/\;D_/\tD_/g' $1.new.txt 
sed -i 's/Ambiguous_taxa//g' $1.new.txt 
sed -i 's/[ \t]*$//' $1.new.txt 

#Expand all rows to contain = # of columns, if column is blank then lca_[whatever last field taxa is]

awk 'BEGIN{FS=OFS="\t"} {if (NF==9) print $0}' $1.new.txt > tmp1.tmp

awk 'BEGIN{FS=OFS="\t"} {if (NF==8) print $0,"lca_"$8}' $1.new.txt > tmp2.tmp

awk 'BEGIN{FS=OFS="\t"} {if (NF==7) print $0,"lca_"$7,"lca_"$7}' $1.new.txt > tmp3.tmp

awk 'BEGIN{FS=OFS="\t"} {if (NF==6) print $0,"lca_"$6,"lca_"$6,"lca_"$6}' $1.new.txt > tmp4.tmp

awk 'BEGIN{FS=OFS="\t"} {if (NF==5) print $0,"lca_"$5,"lca_"$5,"lca_"$5,"lca_"$5}' $1.new.txt > tmp5.tmp

awk 'BEGIN{FS=OFS="\t"} {if (NF==4) print $0,"lca_"$4,"lca_"$4,"lca_"$4,"lca_"$4,"lca_"$4}' $1.new.txt > tmp6.tmp

awk 'BEGIN{FS=OFS="\t"} {if (NF==3) print $0,"lca_"$3,"lca_"$3,"lca_"$3,"lca_"$3,"lca_"$3,"lca_"$3}' $1.new.txt > tmp7.tmp

#combine and remove tmp files
cat tmp*.tmp > $1.new.fixed.txt
rm *.tmp

#correct order and taxonomy separated by semicolons
sed -i 's/\t\(D_[1-6]\)/\;\1/g' $1.new.fixed.txt
sed -i 's/\tlca_/\;lca_/g' $1.new.fixed.txt

awk 'BEGIN{FS=OFS="\t"} {print $1,$3,$2}' $1.new.fixed.txt > $1.taxonomy_fixed.txt

#remove intermediate files
rm $1.new.txt
rm $1.new.fixed.txt
