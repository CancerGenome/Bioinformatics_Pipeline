#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: fast_annovar.sh <Input.vcf.gz>
#      Description: Only VCF.GZ file is accepted here. If you are not faimiliar with GZIP file, please search bcftools and BGZIP.
#                  
#      Author: Wang Yu
#      Mail: yulywang __AT__ umich.edu
#      Created Time: Mon 28 Jan 2019 03:31:51 PM EST
#########################################################################
"
exit
fi

#---- Prepare the required list and input file
bcftools query -l $1 | head -n 1 > $1.one.list
bcftools view -S $1.one.list $1 | bcftools annotate -x INFO -Oz -o $1.one.vcf.gz $1
# Run Annovar here, input your own command line
annovar_vcf $1.one.vcf.gz
bgzip $1.one.vcf.gz.hg19_multianno.vcf;
bcftools index -t $1.one.vcf.gz.hg19_multianno.vcf.gz
bcftools index -t $1
bcftools annotate -a $1.one.vcf.gz.hg19_multianno.vcf.gz -c INFO $1 2>err -Oz -o $1.hg19_annovar.vcf.gz
bcftools index -t $1.hg19_annovar.vcf.gz

#---- Clean all remaining files
rm $1.one.list
rm $1.one.vcf.gz
rm $1.one.vcf.gz.avinput
rm $1.one.vcf.gz.hg19_multianno.txt
rm $1.one.vcf.gz.hg19_multianno.vcf.gz
rm $1.one.vcf.gz.hg19_multianno.vcf.gz.tbi

