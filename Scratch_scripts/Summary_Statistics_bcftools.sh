#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Summary_Statistics_bcftools.sh
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Tue 07 Apr 2020 05:27:12 PM EDT
#########################################################################
"
exit
fi

grep ^SN *.stat |grep record | awk '{print $1"\t"$6}' > Summary_Statistics
grep ^SN *.stat |grep SNPs | awk '{print $1"\t"$6}' >> Summary_Statistics
grep ^SN *.stat |grep indels | awk '{print $1"\t"$6}' >> Summary_Statistics
grep ^TSTV *.stat | awk '{print $1"\t"$8 }' >> Summary_Statistics 
ls *.stat | xargs -i echo bcftools_stats_print_insertion_deletion.pl {} | sed 's/\*//' | sh >> Summary_Statistics 
sed -i 's/\t/,/g' Summary_Statistics
