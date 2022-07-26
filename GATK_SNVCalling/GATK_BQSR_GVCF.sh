#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: BQSR_GVCF.sh -a [BAM] [PREFIX]
#      Description: 
#      Example: FASTQ/AD123.bam FASTQ/AD123
#      Design for BQSR, Apply BQSR and GVCF
#      Assume input is picard after duplication results.
#     
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 26 Feb 2021 11:24:30 PM EST
#########################################################################
"
exit
fi

while getopts ":a" opt; do
  case $opt in
    a)
      echo "-a was triggered!" >&2 
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2 
      ;;
  esac
done

bam=$1
prefix=$2
ref='/home/yulywang/db/human/hs37d5.fa' # for DNA Seq analysis
echo $prefix\.rmdup.bam

echo "Start BaseRecalibration"

gatk4.0.5 BaseRecalibrator \
    -R $ref \
    -I $bam \
	--known-sites  ~/db/dbsnp/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz \
	--known-sites ~/db/dbsnp/1000G_phase1.indels.hg19.sites.vcf.gz \
	--known-sites ~/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz \
	-O $prefix\.recal_data.table; 

gatk4.0.5 ApplyBQSR \
	-R $ref \
	-I $bam \
	-bqsr $prefix\.recal_data.table  \
	-O $prefix\.dup.bq.bam;

echo "Start HaplotypeCaller for whole genome" # only focused on 1-22, X,Y,MT
gatk4.0.5 HaplotypeCaller \
	-R $ref \
	-I $prefix\.dup.bq.bam \
	-O $prefix\.g.vcf.gz \
	--emit-ref-confidence GVCF \
	--max-reads-per-alignment-start 100 \
    -L 1 -L 2 -L 3 -L 4 -L 5 -L 6 -L 7 -L 8 -L 9 -L 10 -L 11 -L 12 -L 13 -L 14 -L 15 -L 16 -L 17 -L 18 -L 19 -L 20 -L 21 -L 22 -L X; 
