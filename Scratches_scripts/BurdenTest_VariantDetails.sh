#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: BurdenTest_VariantDetails.sh  <VCF.GZ> <Sample.list> <Varint List>
#      Description:
#      This is the pipeline for Export details for burden test result
#      Design for Grabbing burden test traditoanlly style details
#      Only output all samples combination, can not output each sample individually because of overwhelm lines
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 06 Dec 2019 10:15:26 AM EST
#########################################################################
"
exit
fi
VCF=$1
SAMPLE=$2
POS=$3

bcftools view -R $POS -S $SAMPLE $VCF | bcftools +fill-tags -- -t AF | call_header4 - 2>err | Collapse_PosV2.pl -s 106 - | cut -f1-47,76- | awk 'BEGIN{OFS="\t"}{print $78,$79,$80,$81,$82,$0}' | sed 's/^GT\t//;s/CHROM/Other\tCHROM/' | cut -f1-82
