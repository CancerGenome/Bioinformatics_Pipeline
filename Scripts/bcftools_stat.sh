#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: stat.sh
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 28 Feb 2020 05:09:47 PM EST
#########################################################################
"
exit
fi

VCF=$1
NUM=`bcftools query -l $VCF | wc -l`
bcftools stats $VCF > $VCF.All.stat
bcftools stats -f PASS $VCF > $VCF.PASS.stat
`bcftools stats -f PASS -i 'AN>='$NUM' * 2 * 0.98' $VCF > $VCF.PASS.CR98.stat` # because bcftools stats can not calculate F_Missing, bcftools view can
#bcftools view -f PASS -i 'F_MISSING<=0.0000001'  $VCF | bcftools stats - > $VCF.PASS.CR98.stat

bcftools stats -i 'Func.refGene="exonic"' $VCF > $VCF.All.exonic.stat
bcftools stats -i 'Func.refGene="exonic"' -f PASS $VCF > $VCF.PASS.exonic.stat
`bcftools stats -f PASS -i 'Func.refGene="exonic" && AN>='$NUM' * 2 * 0.98' $VCF > $VCF.PASS.exonic.CR98.stat` # because bcftools stats can not calculate F_Missing, bcftools view can
#bcftools view -i 'Func.refGene="exonic" && F_MISSING<=0.0000001' -f PASS $VCF | bcftools stats -  > $VCF.PASS.exonic.CR98.stat
