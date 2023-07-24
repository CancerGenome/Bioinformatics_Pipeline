#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/problematic_region.sh -a
#      Description:
#      Given a file with chr pos
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Mon 01 Jun 2020 06:08:36 PM EDT
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

INPUT=$1
awk '{print $1"\t"$2-1"\t"$2}' $INPUT > /tmp/yw.bed
ls /home/yulywang/db/Problem_Region/*.bed| xargs -i echo echo {}\; bedtools intersect -wa -wb -a /tmp/yw.bed -b {} | sh
