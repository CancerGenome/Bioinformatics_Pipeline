#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/GATK_HardFilter.sh <Given Input VCF FILE> <PREFIX>
#      Description:
#      This is designed for Qsub purpose, didn't use local CPU et al
#      1)Given GATK.vcf.gz after CombineGVCF; should be a normalized VCF
#      2)Split as SNPs and Indels;
#      3)Hard Filter: 
#        SNPs:
#		-filter QD < 5.0 -filter QUAL < 50.0 --cluster-size 3  --cluster-window-size 10
#		-filter SOR > 3.0 -filter FS > 60.0 -filter MQ < 40.0 -filter MQRankSum <-12.5 -filter ReadPosRankSum < -8.0
#	     INDELS:
#		-filter QD < 5.0 -filter QUAL < 50.0 --cluster-size 3  --cluster-window-size 10
#		-filter FS > 60.0 -filter ReadPosRankSum < -20.0
#      4)Merge, Sort and Rmdup
#      4)Annovar annotation
#
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 28 Feb 2020 09:16:35 AM EST
#########################################################################
"
exit
fi

VCF=$1;
PREFIX=$2;
PREFIX=${PREFIX%%.vcf.gz}

:<<'BLOCK'
BLOCK
# Prepare file
bcftools view -v snps $VCF | bcftools annotate -x FILTER -Oz -o $PREFIX.snps.vcf.gz 
bcftools view -v indels $VCF | bcftools annotate -x FILTER -Oz -o $PREFIX.indels.vcf.gz
bcftools index -t $PREFIX.snps.vcf.gz
bcftools index -t $PREFIX.indels.vcf.gz
# Hard Filter
gatk4.0.5 VariantFiltration -V $PREFIX.snps.vcf.gz -filter "QD < 5.0" --filter-name "QD5.0" -filter "QUAL < 50.0" --filter-name "QUAL50.0"  -filter "SOR > 3.0" --filter-name "SOR3"  -filter "FS > 60.0" --filter-name "FS60"  -filter "MQ < 40.0" --filter-name "MQ40"  -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5"  -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8"  --cluster-size 3  --cluster-window-size 10  -O $PREFIX.snps.HF_QD5_QUAL50.vcf.gz
gatk4.0.5 VariantFiltration -V $PREFIX.indels.vcf.gz -filter "QD < 5.0" --filter-name "QD5.0" -filter "QUAL < 50.0" --filter-name "QUAL50.0"   -filter "FS > 200.0" --filter-name "FS200"  -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20"  --cluster-size 3  --cluster-window-size 10  -O $PREFIX.indels.HF_QD5_QUAL50.vcf.gz
# Merge together, sort and rmdup
bcftools concat -a  $PREFIX.snps.HF_QD5_QUAL50.vcf.gz $PREFIX.indels.HF_QD5_QUAL50.vcf.gz  -Oz -o $PREFIX.HF_QD5_QUAL50.vcf.gz 
~/bin/bcftools sort -m 2000M $PREFIX.HF_QD5_QUAL50.vcf.gz -Oz -o $PREFIX.HF_QD5_QUAL50.sort.vcf.gz
bcftools norm -d none $PREFIX.HF_QD5_QUAL50.sort.vcf.gz  -Oz -o $PREFIX.HF_QD5_QUAL50.sort.rmdup.vcf.gz
mv $PREFIX.HF_QD5_QUAL50.sort.rmdup.vcf.gz $PREFIX.HF_QD5_QUAL50.vcf.gz
bcftools norm -m -both -f /nfs/turbo/umms-sganesh/yulywang/FMD/RNASeq/db/hg19_phix174.fa $PREFIX.HF_QD5_QUAL50.vcf.gz -Oz -o $PREFIX.HF_QD5_QUAL50.norm.vcf.gz
mv $PREFIX.HF_QD5_QUAL50.norm.vcf.gz $PREFIX.HF_QD5_QUAL50.vcf.gz
bcftools index $PREFIX.HF_QD5_QUAL50.vcf.gz
# Annotate VCF file
annovar_vcf.fastV2 $PREFIX.HF_QD5_QUAL50.vcf.gz >  $PREFIX.HF_QD5_QUAL50.vcf.gz.annovar.log 2>> $PREFIX.HF_QD5_QUAL50.vcf.gz.annovar.log 
bcftools index -t $PREFIX.HF_QD5_QUAL50.vcf.gz

# Clean up files
rm $PREFIX.HF_QD5_QUAL50.sort.vcf.gz
rm $PREFIX.snps.vcf.gz $PREFIX.indels.vcf.gz
rm $PREFIX.snps.vcf.gz.tbi $PREFIX.indels.vcf.gz.tbi
rm $PREFIX.indels.HF_QD5_QUAL50.vcf.gz $PREFIX.snps.HF_QD5_QUAL50.vcf.gz
rm $PREFIX.indels.HF_QD5_QUAL50.vcf.gz.tbi $PREFIX.snps.HF_QD5_QUAL50.vcf.gz.tbi

#bcftools concat -a $PREFIX.snps.HF_QD5_QUAL50.vcf.gz $PREFIX.indels.HF_QD5_QUAL50.vcf.gz |  bcftools reheader -s ~/FMD/SNVCalling_2019/Final_VCF/new_header2 | bgzip --threads 2 > $PREFIX.HF_QD5_QUAL50.rename.vcf.gz
#bcftools index -t $PREFIX.HF_QD5_QUAL50.rename.vcf.gz
