#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/RMSE.sh -a
#      Description:
#      Format: BAM FILE, PREFIX
#      Caveat: Bam should be *Aligned.toTranscriptome.out.bam
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 18 Jun 2021 02:40:55 PM EDT
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
sample_id=`basename $prefix`
db_prefix='/home/yulywang/FMD/RNASeq/db/rsem_reference' 

rsem-calculate-expression \
    --fragment-length-max 1000 \
    --no-bam-output \
    --paired-end \
    --estimate-rspd \
    --forward-prob 0.0 \
    --bam $bam \
    $db_prefix $prefix

