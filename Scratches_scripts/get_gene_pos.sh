#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/get_gene_pos.sh -a
#      Description:
#      Given a gene list, output gene range, only output the longest isoform
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Wed 03 Jun 2020 11:36:35 AM EDT
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

Gene=$1
#grep -wf $Gene ~/db/anno/hg19.map | cut -f1,2,4,5 |  sort -k1,1 -k2,2 -k3n,3 -k4n,4r | uniq |  awk '!a[$1]++'  | tee gene.list.detail | cut -f2-4 | sed 's/chr//' | sort -k1V,1 -k2n,2 -k3n,3 > gene.range
#fetch.pl -q1 -d1 $Gene ~/db/anno/hg19.map | cut -f1,2,4,5 |  sort -k1,1 -k2,2 -k3n,3 -k4n,4r | uniq | tee gene.list.detail |awk '!a[$1]++' | cut -f2-4 | sed 's/chr//' | sort -k1V,1 -k2n,2 -k3n,3 > gene.range
# Use UCSC RefSeq RefFlat, with more genes
fetch.pl -q1 -d1 $Gene ~/db/anno/hg19_RefSeq_RefFlat.gene.txt | cut -f1,3,5,6 |  sort -k1,1 -k2,2 -k3n,3 -k4n,4r | uniq | tee gene.list.detail |awk '!a[$1]++' | cut -f2-4 | sed 's/chr//' | sort -k1V,1 -k2n,2 -k3n,3 > gene.range # select the longest one, this is the previous method
#fetch.pl -q1 -d1 $Gene ~/db/anno/hg19_RefSeq_RefFlat.gene.txt | cut -f1,3,5,6 |  sort -k1,1 -k2,2 -k3n,3 -k4n,4r | uniq | tee gene.list.detail |cut -f2-4|sort -k1V,1 -k2n,2 |bedtools merge  -i stdin > gene.range  # output all variants
