#!/bin/bash
if [ $# -le 1 ] 
	then echo "
#########################################################################
#      USAGE: strelka.sh <sample_list_file> <Output Shell file> <Output Directory> 
#
#      Description: Submit strelka analysis, when input match normal and tumor samples
#
#      File format: Normal Tumor (per line, with full path, separate with tab OR gap)
#
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 15 Jan 2016 02:49:38 PM EST
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

if [ -e $output.ReverseNT ]
	then rm $output.ReverseNT;
fi
# generate scripts
while read line 
do 
	normal=`echo $line | cut -d" " -f1`
	tumor=`echo $line | cut -d" " -f2`
	dir=${tumor%/*.bam} # usre directory
	short=${tumor%.bam}
	#short=${normal%.bam} # design for reverse strelka 
	short=${short%_rmdup_realigned}
	short=${short##*/} # only get prefix
	short_RT=$short"_RT"
if [ $# -ge 3 ] 
	then dir=$3
fi
	cmd="/home/yulywang/bin/tar/strelka_workflow-1.0.15/bin/configureStrelkaWorkflow.pl --normal=$normal --tumor=$tumor --ref=/home/yulywang/db/human/hs37d5.fa  --config=/home/yulywang/bin/tar/strelka_workflow-1.0.15/etc/strelka_config_isaac_default.ini --output-dir=$dir/$short; cd $dir/$short ; make -j 4"
	echo $cmd >> $output
	cmd="/home/yulywang/bin/tar/strelka_workflow-1.0.15/bin/configureStrelkaWorkflow.pl --normal=$tumor --tumor=$normal --ref=/home/yulywang/db/human/hs37d5.fa  --config=/home/yulywang/bin/tar/strelka_workflow-1.0.15/etc/strelka_config_isaac_default.ini --output-dir=$dir_RT/$short_RT; cd $dir_RT/$short_RT ; make -j 4"
	echo $cmd >> $output.ReverseNT
done < $input
#-- Qsub 
#batchqsub.pl $output
exit
