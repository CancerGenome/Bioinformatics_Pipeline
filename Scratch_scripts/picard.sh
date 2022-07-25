#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: picard.sh INPUT_BAM Sample_ID
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 01 Nov 2019 04:48:25 PM EDT
#########################################################################
"
exit
fi
bam=$1
prefix=$2
echo $prefix\.rmdup.bam

# Specifical design for wrong header file from STAR , will not use this next time
#samtools view -H $bam | change_header.pl - | samtools reheader - $bam > $prefix.newheader.bam
#samtools view -H $bam | change_header.pl -  | samtools reheader - $bam | samtools view -h | sed 's/\\tSM/ SM/' | samtools view -b > $prefix.newheader.bam

java -jar ~/bin/picard.jar \
    MarkDuplicates I=$bam \
    O=$prefix\.rmdup.bam \
    M=$prefix\.marked_dup_metrics.txt \
    ASSUME_SORT_ORDER=coordinate
