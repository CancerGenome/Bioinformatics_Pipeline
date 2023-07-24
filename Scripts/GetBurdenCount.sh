#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/GetBurdenCount.sh -a <VCF> <GeneList> <SampeList>
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Thu 04 Jun 2020 10:48:37 PM EDT
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
VCF=$1
GENELIST=$2
SAMPLE=$3
cat LOF_Nonsyn_0.01/group.file  | fetch.pl -q1 -d1 $GENELIST - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > LOF_Nonsyn_0.01/pos.list1
cat LOF_Nonsyn_0.05/group.file  | fetch.pl -q1 -d1 $GENELIST - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > LOF_Nonsyn_0.05/pos.list1
BurdenTest_VariantDetails.sh $VCF $SAMPLE LOF_Nonsyn_0.01/pos.list1 > LOF_Nonsyn_0.01/burden.1e-2.details1
BurdenTest_VariantDetails.sh $VCF $SAMPLE LOF_Nonsyn_0.05/pos.list1 > LOF_Nonsyn_0.05/burden.1e-2.details1
