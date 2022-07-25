#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/check_MGI.sh <Input gene list>
#      Description:
#      As final result does not include gene, it's best to query one by one
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 01 Mar 2019 10:14:52 PM EST
#########################################################################
"
exit
fi

fetch.pl -q1 -d1 $1 ~/db/MGI/Human_Mouse_Orthology  | cut -f5 |grep -wf - ~/db/MGI/Gene_MP | fetch.pl -q4 -d1 - ~/db/MGI/MP_phenotype  | less -S
