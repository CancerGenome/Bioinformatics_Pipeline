#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/IGV.auto.sh -a
#      Description:
#      Input: ID chr pos
#      Output: IGV2015, IGV2019
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Tue 28 Jul 2020 03:39:37 PM EDT
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
POS=$1
fetch.pl -pq1 -d3 $POS ~/bin/FMD.sample.info  | awk '$NF==1' | cut -f1-3 | IGV.pl -p "/home/xiaozhu/igv/Quick" - | sed 's/\\/\//' > IGV.2015
fetch.pl -pq1 -d3 $POS ~/bin/FMD.sample.info  | awk '$NF==2' | cut -f1-3 | IGV.pl -p "/home/xiaozhu/igv/Quick2" -P "dup.bq.bam" -| sed 's/\\/\//'> IGV.2019
