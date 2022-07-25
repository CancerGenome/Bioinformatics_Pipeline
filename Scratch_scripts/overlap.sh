#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/overlap.sh -a
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Sat 30 May 2020 10:46:27 PM EDT
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

bedtools intersect -wa -wb $@
