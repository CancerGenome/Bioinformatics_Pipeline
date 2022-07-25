#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/hwe.sh
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Wed 15 Apr 2020 09:42:42 PM EDT
#########################################################################
"
exit
fi

bcftools plugin fill-tags -- -t HWE 
