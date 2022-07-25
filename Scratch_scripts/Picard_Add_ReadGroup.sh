#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Picard_Add_ReadGroup.sh BAM_FILE PREFIX
#      Description:
#      Bam: a.bam
#      Prefix: a, this will be used as ID in the bam
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Tue 13 Oct 2020 04:50:07 PM EDT
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
java -jar ~/bin/picard.jar AddOrReplaceReadGroups \
      I=$bam \
      O=$prefix\.bam \
      RGID=$prefix \
      RGLB=$prefix \
      RGPL=Illumina \
      RGPU=unit1 \
	  RGCN=University_of_Michigan_Ganesh_Lab_YuWang \
      RGSM=$prefix
mv $bam  /nfs/turbo/umms-sganesh/yulywang/FMD/RNASeq/PedRNA/Bam/tmp
mv $bam\.bai  /nfs/turbo/umms-sganesh/yulywang/FMD/RNASeq/PedRNA/Bam/tmp
mv $prefix\.bam $bam
samtools index $bam
