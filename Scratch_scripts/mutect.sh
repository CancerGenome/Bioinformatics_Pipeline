#!/bin/bash
# This version is based on original mutect.sh from MBNI, but change the structure here.
if [ $# -le 1 ] 
	then echo "
#########################################################################
#      USAGE: mutect.sh <sample_list_file> <Output Shell file> <Output Directory> <Sep Chromosome File>
#
#      Description: Submit mutect analysis, when input match normal and tumor samples
#                   Orignal files was created by Qingxuan: /home/junzli_lab/qsong/new_script/Mutect.0530.sh;
#                   <Sep Chromosome Model> Set to 1, if you try to run chromosome one by one
#                                          Default to 0. 
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
HOME="/home/yulywang"
#source $HOME/.bashrc
reference="$HOME/db/human/hs37d5.fa"
dbsnp="$HOME/db/dbsnp/dbsnp_137.b37.vcf" 
cosmic="$HOME/db/cosmic/b37_cosmic_v54_120711.vcf" 
bedfilev5="$HOME/db/anno/agilent_exome_v5_Regions.bed"
bedfile_nimblegenv3="$HOME/db/anno/SeqCap_EZ_Exome_v3_primary_0-based.targetinterval.wheader.bed"
#mutect="$HOME/bin/tar/jdk1.6.0_45/bin/java -Xmx6g -Djava.io.tmpdir=/tmp -jar $HOME/bin/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence $reference --dbsnp $dbsnp --cosmic $cosmic " 
#mutect="$HOME/bin/tar/jdk1.6.0_45/bin/java -Xmx6g -Djava.io.tmpdir=/home/junzli_lab/yulywang/tmp/mutect_tmp -jar $HOME/bin/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence $reference --dbsnp $dbsnp --cosmic $cosmic --num_threads 4 --downsample_to_coverage 10000 --max_alt_alleles_in_normal_count 4"
#mutect="$HOME/bin/tar/jdk1.6.0_45/bin/java -Xmx6g -Djava.io.tmpdir=/home/junzli_lab/yulywang/tmp/mutect_tmp -jar $HOME/bin/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence $reference --dbsnp $dbsnp --cosmic $cosmic --num_threads 4 --max_alt_alleles_in_normal_count 4"
#mutect="$HOME/bin/tar/jdk1.6.0_45/bin/java -Xmx6g -Djava.io.tmpdir=/home/junzli_lab/yulywang/ESCC/tmp -jar $HOME/bin/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence $reference --dbsnp $dbsnp --cosmic $cosmic "  # get more space on local disk tmp file
input=$1 
output=$2
dir=$3
dir_RT=$3"_RT"
chr_model=0

# Check parameters and directories
if [ $# -ge 3 ] 
	then dir=$3
fi

if [ -n "$4" ] # check exists
	then chr_model=$4
		echo "Chromosome Model:" $chr_model
fi

if [ -e $output ]
	then rm $output;
fi

if [ -e $output.ReverseNT ]
	then rm $output.ReverseNT;
fi

if [ -d $dir/tmp ]; then 
	echo "exits tmp directory"
else mkdir $dir/tmp
fi

# generate scripts
while read line 
do 
	normal=`echo $line | cut -d" " -f1`
	tumor=`echo $line | cut -d" " -f2 `
	#dir=${tumor%/*.bam} # usre directory
	short=${tumor%.bam}
	#short=${normal%.bam} # design for reverse mutect
	short=${short##*/} # only get prefix
	short_RT=$short"_RT"

if [ -d $dir/tmp/$short ]; then 
	rm -rf $dir/tmp/$short
	echo "RM $dir/tmp/$short"
else mkdir $dir/tmp/$short
	echo "mkdir $dir/tmp/$short"
fi

	mutect="~/bin/tar/jdk1.6.0_45/bin/java -Xmx6g -Djava.io.tmpdir=$dir/tmp/$short -jar ~/bin/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence ~/db/human/hs37d5.fa --dbsnp ~/db/dbsnp/dbsnp_137.b37.vcf --cosmic ~/db/cosmic/b37_cosmic_v54_120711.vcf --num_threads 1 --downsample_to_coverage 10000 --max_alt_alleles_in_normal_count 4"

if [ $chr_model -eq 1 ]
	then   # open chromosome model
	for i in `awk '{print $1}' /home/yulywang/db/human/hs37d5.interval.list | head -n 25 `; do
	#for i in `awk '{print $1}'  /home/junzli_lab/yulywang/ESCC/list/hs37d5.interval.list.1M `; do
		cmd="$mutect --input_file:normal $normal --input_file:tumor $tumor --out $dir/$short"_mutect_cal_stats.$i.out" --vcf $dir/$short"_mutect.$i.vcf" --intervals $i" 
		echo $cmd >> $output
	done
else
	cmd="$mutect --input_file:normal $normal --input_file:tumor $tumor --out $dir/$short"_mutect_cal_stats.out" --vcf $dir/$short"_mutect.vcf" --intervals /home/yulywang/db/human/hs37d5.interval.list" 
	echo $cmd >> $output
	cmd="$mutect --input_file:normal $tumor --input_file:tumor $normal --out $dir_RT/$short_RT"_mutect_cal_stats.out" --vcf $dir_RT/$short_RT"_mutect.vcf" --intervals /home/yulywang/db/human/hs37d5.interval.list" 
	echo $cmd >> $output.ReverseNT
fi

#	echo $normal $tumor $short
	#cmd="$mutect --input_file:tumor $tumor --input_file:normal $normal --out $short"_mutect_cal_stats.out" --vcf $short"_mutect_mutation.vcf" --coverage_file $short"_mutect_coverage.wig.txt"" 
	#cmd="$mutect --input_file:normal $normal --input_file:tumor $tumor --out $dir/$short"_mutect_cal_stats.out" --vcf $dir/$short"_mutect_mutation.vcf" --intervals /home/junzli_lab/yulywang/ESCC/list/hs37d5.interval.list " 
	#cmd="$mutect --input_file:normal $normal --input_file:tumor $tumor --out $dir/$short"_mutect_cal_stats.out" --vcf $dir/$short"_mutect_mutation.vcf" --intervals /home/junzli_lab/yulywang/ESCC/data/panel.span100.bed "  # design for panel bed file
	#echo $cmd >> $output
done < $input
#-- Qsub 
#batchqsub.pl $output
exit
