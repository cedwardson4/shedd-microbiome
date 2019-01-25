#!/bin/bash

#LEFT_READ=$1
#RIGHT_READ=$2
#####SAMPLE_NAME=$1

cd ~/Desktop/LHMG/adapter_trimmed_fastqs/sickle_trimmed_fastqs

bbmerge.sh -Xmx40g threads=4 in=$1\_L001_R1_001_trimmed_sickle.fastq \
  in2=$1\_L001_R2_001_trimmed_sickle.fastq \
  out=$1\_merged.fq \
  adapters=/home/christian/bbmap_37.66/resources/adapters.fa \
  outu1=$1\_unmerged_R1.fq \
  outu2=$1\_unmerged_R2.fq
 
metaspades.py -1 $1\_unmerged_R1.fq \
  -2 $1\_unmerged_R2.fq \
  -s $1\_merged.fq \
  -t 4 -m 47 -o $1\_merged_metaspades_default_out/
  
cp $1\_merged_metaspades_default_out/scaffolds.fasta $1\_merged_metaspades_default_out.scaffolds.fasta

bwa index $1\_merged_metaspades_default_out.scaffolds.fasta
bwa mem -t 4 $1\_merged_metaspades_default_out.scaffolds.fasta $1\_L001_R1_001_trimmed_sickle.fastq $1\_L001_R2_001_trimmed_sickle.fastq \
  > $1\_merged_metaspades_default_out.scaffolds.fasta.aln-pe.sam
  
samtools view -bS $1\_merged_metaspades_default_out.scaffolds.fasta.aln-pe.sam | samtools sort - -o $1\_merged_metaspades_default_out.scaffolds.fasta.aln-pe.sorted.bam

~/metabat/runMetaBat.sh $1\_merged_metaspades_default_out.scaffolds.fasta $1\_merged_metaspades_default_out.scaffolds.fasta.aln-pe.sorted.bam

checkm lineage_wf -x fa -t 4 $1\_merged_metaspades_default_out.scaffolds.fasta.metabat-bins/ $1\_merged_metaspades_default_out.scaffolds.fasta.metabat-bins/checkm > $1\_merged_metaspades_default_out.scaffolds.fasta.metabat-bins/checkm.stats

checkm qa -o 2 $1\_merged_metaspades_default_out.scaffolds.fasta.metabat-bins/checkm/lineage.ms $1\_merged_metaspades_default_out.scaffolds.fasta.metabat-bins/checkm -f $1\_merged_metaspades_default_out.scaffolds.fasta.metabat-bins/checkm/extended_stats.txt