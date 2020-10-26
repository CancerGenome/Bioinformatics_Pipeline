#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/QC_forBurdenTest.generateVCF.sh <Sample list> <VCF file> <Prefix>
#      Description:
#      Given the final sample list, VCF file and prefix, 
#      Generate CR98, PASS, allele_cout >=1 , HWE >= 0.001 result
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Sun 19 Apr 2020 05:45:42 PM EDT
#########################################################################
"
exit
fi

SAMPLE=$1;
VCF=$2;
PREFIX=$3;

bcftools view -S $SAMPLE -f PASS -c 1 -i 'F_MISSING<=0.02' $VCF | bcftools +fill-tags  -- -t HWE | bcftools view -e 'HWE<1e-3' | bgzip --threads 16 > $PREFIX\.vcf.gz
bcftools index -t $PREFIX\.vcf.gz
epacts anno -db gencodeV19 -in $PREFIX\.vcf.gz -out $PREFIX\.vcf.gz.epacts.vcf.gz
bcftools index -t $PREFIX\.vcf.gz.epacts.vcf.gz
