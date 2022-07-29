#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: picard.sh INPUT_BAM Sample_ID
#      Description:
#      Should follow Picard_Add_ReadGroup.sh if mapped with STAR (noRG)
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

java -jar ~/bin/picard.jar \
    MarkDuplicates I=$bam \
    O=$prefix\.rmdup.bam \
    M=$prefix\.marked_dup_metrics.txt \
    ASSUME_SORT_ORDER=coordinate
