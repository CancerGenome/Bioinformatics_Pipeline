#!/bin/bash
if [ $# -le 1 ] 
	then echo "
#########################################################################
#      File Name: /home/yulywang/bin/varscan.sh <sample list file> <output shell > <output directory>
#
#      Description: Submit varscan analysis, when input match normal and tumor bam
#
#       Author: Wang Yu
#       Mail: wangyu.bgi@gmail.com
#       Created Time: Wed 08 Feb 2017 02:33:59 PM EST
#
#########################################################################
"
exit
fi
#-- Configure files
input=$1 
output=$2
dir=$3
dir_RT=$3"_RT"

if [ -e $output ]
	then rm $output;
fi
if [ -e $output.2 ]
	then rm $output.2;
fi
if [ -e $output.ReverseNT ]
	then rm $output.ReverseNT;
fi
# generate scripts
foo=0

while read line 
do 
	normal=`echo $line | cut -d" " -f1`
	tumor=`echo $line | cut -d" " -f2`
	dir=${tumor%/*.bam} # usre directory
	short=${tumor%.bam}
	#short=${normal%.bam} # design for reverse strelka 
	short=${short%_rmdup_realigned}
	short=${short##*/} # only get prefix
	prefix=$short
	prefix_RT=$short"_RT"
if [ $# -ge 3 ] 
	then dir=$3
fi
cmd="normal_pileup=\"samtools mpileup -q 1 -f /home/yulywang/db/human/hs37d5.fa $normal \";tumor_pileup=\"samtools mpileup -q 1 -f /home/yulywang/db/human/hs37d5.fa $tumor \"; bash -c \"java -jar ~/bin/VarScan.v2.2.3.jar somatic <(\$normal_pileup) <(\$tumor_pileup) $dir/$prefix\"; "
echo $cmd >> $output
cmd="normal_pileup=\"samtools mpileup -q 1 -f /home/yulywang/db/human/hs37d5.fa $tumor \";tumor_pileup=\"samtools mpileup -q 1 -f /home/yulywang/db/human/hs37d5.fa $normal \"; bash -c \"java -jar ~/bin/VarScan.v2.2.3.jar somatic <(\$normal_pileup) <(\$tumor_pileup) $dir_RT/$prefix_RT\"; "
echo $cmd >> $output.ReverseNT

#---- For each chromosome
#for i in `awk '{print $1}' /home/yulywang/db/human/hs37d5.interval.list | head -n 25 `; do
#cmd="normal_pileup_$foo=\"samtools mpileup -q 1 -r $i -f /home/yulywang/db/human/hs37d5.fa $normal \";tumor_pileup_$foo=\"samtools mpileup -q 1 -r $i -f /home/yulywang/db/human/hs37d5.fa $tumor \"; bash -c \"java -jar ~/bin/VarScan.v2.2.3.jar somatic <(\$normal_pileup_$foo) <(\$tumor_pileup_$foo) $dir/$prefix.$i \" & "
#foo=$(($foo+1))
#echo $cmd >> $output.2
#done

done < $input
#-- Qsub 
#batchqsub.pl $output
exit
