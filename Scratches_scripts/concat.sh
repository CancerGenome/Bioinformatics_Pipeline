#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: concat.sh  <Input.vcf.gz> 
#      After annotation on each chr, concat together, then re-annotate
#                  
#      Author: Wang Yu
#      Mail: yulywang __AT__ umich.edu
#      Created Time: Mon 28 Jan 2019 03:31:51 PM EST
#########################################################################
"
exit
fi
T=8

#bcftools concat --threads $T \
#$1.1.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.2.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.3.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.4.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.5.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.6.tmp.vcf.gz.hg19_multianno.vcf.gz  \
#$1.7.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.8.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.9.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.10.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.11.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.12.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.13.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.14.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.15.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.16.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.17.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.18.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.19.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.20.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.21.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.22.tmp.vcf.gz.hg19_multianno.vcf.gz \
#$1.X.tmp.vcf.gz.hg19_multianno.vcf.gz \
#-Oz -o $1.annovar.vcf.gz
#bcftools index --threads $T $1.annovar.vcf.gz
bcftools annotate  --threads $T -a $1.annovar.vcf.gz -c INFO $1 2>err -Oz -o $1.hg19_annovar.vcf.gz
bcftools index --threads $T $1.hg19_annovar.vcf.gz
#$1.Y.tmp.vcf.gz.hg19_multianno.vcf.gz \
