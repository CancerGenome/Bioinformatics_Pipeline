#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Genotype_Concordance.sh
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Tue 18 Feb 2020 09:18:49 PM EST
#########################################################################
"
exit
fi
VCF=$1;
SAMPLE1=$2;
SAMPLE2=$3;

mkdir $SAMPLE1;
cd $SAMPLE1;

bcftools query -s $SAMPLE1,$SAMPLE2 -f '[%GT\t]\n' $VCF | quniq.pl -c1,2 - > $SAMPLE1.stat
awk '$1!~/2|3|4/ && $2!~/2|3|4|5|6/' $SAMPLE1.stat | trans_statsV4.pl -  > $SAMPLE1.trans
