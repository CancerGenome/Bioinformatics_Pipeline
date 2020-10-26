#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: check_brave.hg19.sh
#      Description: Given hg19 version chr pos, liftto hg38 and check the bravo hg38 variant
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Mon 19 Aug 2019 01:48:07 PM EDT
#########################################################################
"
exit
fi

awk '{print "chr"$1"\t"$2"\t"$2+1}' $1 > /tmp/pos.old
liftOver /tmp/pos.old ~/bin/hg19ToHg38.over.chain.gz /tmp/pos.new unmap
cut -f1,2 /tmp/pos.new > /tmp/pos.new1
bcftools view -R /tmp/pos.new1 ~/FMD/Pathogenic/Bravo/bravo.hg38.vcf.gz 
