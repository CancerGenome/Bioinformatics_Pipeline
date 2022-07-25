#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Chip_Annotation.sh <INPUT CHIP FILE>
#      Description:
#      Add the MGI correct ref/alt and ANNOVAR annotation. Check the beginning commponent of INFO field. 
#      
#      Basic idea: Right MGI VCF -> Annovar annotation -> Create custom annotation file -> bcftools annotate to new files
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Wed 12 Feb 2020 02:57:18 PM EST
#########################################################################
"
exit
fi

prefix=/home/yulywang/FMD/GWAS_genotype/MGI
input=$1
#bcftools annotate  -x INFO/AC,INFO/AN $prefix/MGI_1_1.sort.vcf.gz.hg19_annovar.vcf.gz | bcftools view -H | perl $prefix/prepare_info.pl - 2> $prefix/anno.header | bgzip --threads 4 > $prefix/anno.forbcftools.gz
#tabix -S1 -s1 -b2 -e2 $prefix/anno.forbcftools.gz
bcftools annotate -a $prefix/anno.forbcftools.gz -c CHROM,POS,-,ADD -h $prefix/anno.header $input | less -S
