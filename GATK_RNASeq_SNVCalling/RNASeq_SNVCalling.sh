#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: RNA-Seq calling pipeline BAM PREFIX
#      Description:
#      BAM should be the full directory of bam
#      PREFIX should have full directory
#      Example: /home/yulywang/abc/a.bam /home/yulywang/abc/a
#
#      Details:
#      Start with rmdup bam file, 
#      Step 1: Split Reads with N in Cigar, use for RNA-Seq SNV calling only
#      Step 2: Base recalibration
#      Step 3: Haplotypecaller and generate gvcf
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 01 Nov 2019 04:48:25 PM EDT
#########################################################################
"
exit
fi
bam=$1
prefix=$2
ref='/nfs/turbo/umms-sganesh/yulywang/FMD/RNASeq/db/hg19_phix174.fa' # this reference has chr, which is used in RNASeq mapping

echo $prefix
echo "Start SplitNCigar Reads"
gatk4.0.5 SplitNCigarReads \
  -R $ref \
  -I $bam \
  -O $prefix\.splitNCigar.bam

echo "Start BaseRecalibration"
gatk4.0.5 BaseRecalibrator \
	-R $ref \
	-I $prefix\.splitNCigar.bam \
    --known-sites  ~/db/dbsnp/withchr/Mills_and_1000G_gold_standard.indels.hg19.sites_chr.vcf.gz \
	--known-sites ~/db/dbsnp/withchr/1000G_phase1.indels.hg19.sites_chr.vcf.gz \
	--known-sites ~/db/dbsnp/withchr/dbsnp_138.hg19.excluding_sites_after_129_chr.vcf.gz \
	-O $prefix\.recal_data.table;

gatk4.0.5 ApplyBQSR \
	-R $ref \
	-I $prefix\.splitNCigar.bam \
	-bqsr $prefix\.recal_data.table \
	-O $prefix\.dup.bq.bam;

# echo "Start HaplotypeCaller for chr17"
# gatk4.0.5 HaplotypeCaller \
#	-R $ref \
#	-I $prefix\.dup.bq.bam \
#	-O $prefix\.NF1.g.vcf.gz \
#	--emit-ref-confidence GVCF \
#    --L  chr17:29421945-29704695 \
#	--max-reads-per-alignment-start 100;

echo "Start HaplotypeCaller for whole genome"
gatk4.0.5 HaplotypeCaller \
	-R $ref \
	-I $prefix\.dup.bq.bam \
	-O $prefix\.g.vcf.gz \
	--emit-ref-confidence GVCF \
	--max-reads-per-alignment-start 100;
