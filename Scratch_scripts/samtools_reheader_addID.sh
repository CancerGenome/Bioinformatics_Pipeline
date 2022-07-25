#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/samtools_reheader_addID.sh -a
#      Description:
#      Input: Input.bam Prefix
#      Prefix will be used for adding one RG line
#      @RG	ID:PREFIX	PL:Illumina	LB:PREFIX	DS:pe::0	DT:2020-01-01	SM:PREFIX	CN:University_of_Michigan_Ganesh_Lab_YuWang
#
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Sat 10 Oct 2020 05:49:26 PM EDT
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

bam=$1
prefix=$2
samtools view -H $bam |grep -v ^\@RG > $prefix\.header
echo $prefix | perl -ane '{print "\@RG\tID:$F[0]\tPL:Illumina\tLB:$F[0]\tDS:pe::0\tDT:2020-01-01\tSM:$F[0]\tCN:University_of_Michigan_Ganesh_Lab_YuWang\n"}' - >> $prefix\.header
samtools reheader -i $prefix\.header $bam > $bam\.replace
rm $prefix\.header
mv $bam\.replace $bam
samtools index $bam
