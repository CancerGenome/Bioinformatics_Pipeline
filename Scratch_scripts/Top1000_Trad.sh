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
sort -k37,37g variant.forexcel | head -n 1000 > Top1000
# no need to generate the top variants, use the top100
