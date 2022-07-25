#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Annotate_Gene_For_Bed.sh -a
#      Description:
#      Given a bed file, add all genes for this bed, (hg19)
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Wed 16 Sep 2020 01:14:01 PM EDT
#########################################################################
"
exit
fi

source activate cnvkit
cnvkit.py target $1 --annotate /home/yulywang/db/list/refFlat.nochr.txt -o $1.withgene.output
source deactivate cnvkit
