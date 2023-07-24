#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Top1000.sh -a <PREFIX>
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Sat 18 Jul 2020 09:35:38 PM EDT
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

PREFIX=$1
sort -k19,19g variant.forexcel | head -n 1000 > Top1000
awk '$19<=0.05' Top1000 | fetch.pl -q1 -d21 - $PREFIX\.burden.detail > Top1000.variant
wc -l Top1000.variant Top1000
