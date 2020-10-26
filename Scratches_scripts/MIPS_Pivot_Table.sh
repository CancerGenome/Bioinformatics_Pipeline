#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/MIPS_Pivot_Table.sh -a
#      Description:
#      Input: MIPS gene list, first column gene list name, followed by genes
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Wed 05 Aug 2020 05:14:09 PM EDT
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

/home/yulywang/bin/pivot_table.mips.gene.list.pl $INPUT |trans_statsV4.pl -  |  sort -k2n,2r -k3n,3r -k4n,4r -k5n,5r -k6n,6r -k7n,7r -k8n,8r -k9n,9r -k10n,10r -k11n,11r -k12n,12r -k13n,13r -k14n,14r -k15n,15r -k16n,16r -k17n,17r -k18n,18r -k19n,19r -k20n,20r -k21n,21r 
