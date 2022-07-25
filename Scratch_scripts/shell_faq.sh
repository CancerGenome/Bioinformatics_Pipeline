All SHELL TIPS

Parameters
$# : parameters num 
$$ : shell pid
$0 : filename 
$1,$2,$@: display all parameters
$? : check run success for previous command

Variable

	Read variant: then input value is given to variant
	Use of '' : echo '$myvar' = $myvar   echo "$myvar" =abc
	$PS1: set your login windows "www@wulab~:"  export PS1="www@wulab\w:"
	Define : $myvar="abc"
	Bigger : "foo" -le 20 # should have gap
	Combine: V1="Hello" V2="World" V3=${V1}${V2}

	Add 1: V1=1 V2=2 let V3=$V1+$V2
	Add 2: V1=1 V2=2 echo $(($V1+$V2))
	Add 3: V1=1 V2=2 echo $[$A+$B]
	Add 4: V1=1 V2=2 expr $A + $B
	Add 5: V1=1 V2=2 echo $A+$B | bc
	Add 6: V1=1 V2=2 awk 'BEGIN{print '"$A"' + '"$B"'}'

	Quote: '' no variable change; "" use real value of variable

	Array: array={"Hi" "my" "name" "is"}
	echo ${array[@]}
	echo ${array[1]}
	array[333]="New Array"

String Control:

	substring: echo ${variable:x:y} # echo variable from x to y position
	length: echo ${#variable}
	-5 length: echo ${variable: -5}

	${pa:-default} : if parameter does not exists, as defaul
	${#pa} : give length of pa
	${pa%word}  /${pa#word} : non greedy regrex, 
	${pa%%word} /${pa##word} : greedy regrex, remove after word OR before word
	example: we can get local directory by ${bar%%*/}

Control Loop command : if and elif for while case

	for foo in a b c; do echo $foo;  done
	for i in {0..100..3}; do echo $i; done
	for i in `seq 10`; do echo $i; done
	for kmer in $(seq 50 50 250); do done
		
	while [ "$foo" -le 20 ]  # le means less than 20 first defined foo =1 
		foo=$(($foo+1))     # strict for foo cycle

		foo=1
		while [ $foo -le 5 ]
		do
			echo "Welcone $foo times"
			foo=$(($foo+1))     # strict for foo cycle
		done
	until
		until who |grep "$1" > /dev/null  # to check who is logging in and give alert
		do  sleep 60  done
		echo -e \\a
		echo "$1 has logged in"
	case 
		case "$condition" in 
			yes )    echo "Yes";;
			no )    echo "No";;
			*)	echo "Sorry";;
			yes |y | Yes |YES ) echo "Yes " 
								echo "another Yes"  # can merge condition
								;;      # do multiple things for one case
			[nN]* )  ........ do something
		esac

check or test if:  command test or [ (always works with ])
	if test -f check.file  //      if [ -f check.file ]; then
		following are function of test : string compare/math compare/file check
			string compare: A=B  A!=B  -n string(check exist)  -z string (check not exists)
			if [ -n "$4" ] # check exists -z for check not exists
				then
			fi
			math compare: exp1 -eq exp2 -ne -gt -ge -lt -le ! (all same with perl )
			example of string compare : if [ "$gender" = 'f' ]; then 
			file check: -d file (whether directory)
						-e file (exists) -r read -w -x -s (length is zero)

rsync -avP -rsh=ssh file destination
rsync -n -avz -r --delete file destination, do not delete, tell you which files will be delted, without -n, will delete directly, should with -r 
rsync -avuh -r --delete
rsync -avuh file destination, common use for archive files. a archive, v verbose ,h human readable, u : keep newer files


Sort:  sort -k1V,1 -k2n,2 # sort first as version, like 1 -> M, X, Y, then position
rm : rm -i, remove files after checking

Draw a directory tree:
tree -hF

Interative Shell

	/usr/bin/expect << EOD
	spawn rsync -ar ${line} ${desthost}:${destpath}
	expect "*?assword:*"
	send "${password}\r"
	expect eof
EOD

Function example:
	
	yes(){
		echo "Name $* ?"
			while true
			do 
			echo -n "Enter Yes or No:"
			read x
			case "$x" in 
				[yY]* ) return 0;;
				[nN]* ) return 1;;
				*)	echo "Answer Yes or No" 
			esac
			done

	}
	echo "Original are $*"
	for i in $@
	do
	if  yes "$i"
	then 
		echo "Hi $i, nick name"
	else
		echo "Never Mind"
	fi
	done

	exit 0

Internal command: break : continue . echo eval exec exit export expr printf return set shift trap unset 
	break : quit from "for while until "
		if [ -d "$file"]; then 
			break
		fi
	: alias of ture, internal and quick
		while : == while true
		: ${var:=value}   check variant
	continue: same with others
	. : run current shell and will keep change of env for this command, while others will not
	eval : as math 
		foo =10 x=foo y="$"$x echo y  (output is $foo)
		foo =10 x=foo eval y='$'$x echo y (output is 10) 
	exec : confusied ?????????
	exit 0 : run success 
	exit 1 : else      do a check :[ -f .profile ] && exit o || exit 1 
	export : export parent variant to child shell
		child.sh: echo "$foo"; echo "$bar"
		parent.sh: foo ="foo will not be printed";export bar="print will be bar"; ./child.sh 
		display: echo $bar no $foo for no export used
	expr	: math calculation, replaced by $(())
		x=`expr $x + 1`
		x=$(expr $x + 1)
		always used : | & = > < != += - * / %
	printf(same with others)
	return: defalut return exit code of last command 
	set : same with split in perl
	shift : shift parameters 
		while [ "$1" != "" ]; do
			echo "$1"
			shift
		done
		exit 0
	unset : delete variant   // unset foo 
	find:  find . \(-name *.1 or -name *.2)\ -type -f -print

Sed
    sed -n '3~100p' print Line number~100 = 3
    sed '/N/'d non_valid_list delete match N
    sed -n '/y/p' non_valid_list delete match N
    sed 's/str1/rep1/;s/str2/rep2/'
    sed -i  's/ \+/\t/g' file # change all blank to tab
	sed '/regex/{x;p;x;}' # add one line before
	sed '/regex/G' # add after this line
	sed '/regex/{x;p;x;G;}' # add before and after this line
	sed '1G' # add one after this line
	sed "s/$replace/$after_replace/g" FILE. variable substitution; use quote
	sed "s/'//g" FILE replace ' apostrophe

:<<'BLOCK'
    MASK all these scripts
BLOCK

Here-doc usage:
	INPUT large scale doc
		cat <<!FUNKY!
		hello 
		this is a here document
!FUNKY! 
	Work as a marco 
		for example we have file test_file :
		www
		yyy
		we can edit this file like this in shell
		vi test_file <<!FunkyStuff!
		1	# go to  line one
		d	# delete this line
		:s/y/x/g	# substitution
		wq	#quit
!FunkyStuff!
!FUNKY!

SHELL option
	sh -n test.sh # check syntax 
	sh -v test.sh # first display shell then run 
	sh -x test.sh # give working process of this shell

SHELL HEADER

if [ $# -le 1 ] 
	        then echo "
				#########################################################################
				#      USAGE: mutect.sh <sample_list_file> <Output Shell file>
				#      Description: Submit mutect analysis, when input match normal and tumor samples
				#                   File format: Normal Tumor (per line, with full path)
				#      Author: Wang Yu
				#      Mail: yulywang@umich.edu
				#      Created Time: Fri 15 Jan 2016 02:49:38 PM EST
				#      Created by Qingxuan: /home/junzli_lab/qsong/new_script/Mutect.0530.sh;
				#      Modified by Wang Yu
				#########################################################################
				"
			fi
			#!/bin/bash

########------------ SMALL TIPS for Different SHELL COMMAND -----------------------
bedtools 
    bedtools intersect -a A.bed -b B.bed -wa -wb -sorted # general 
    bedtools intersect -a A.bed -b B.bed -wo # report number of sites overlap

Lftp:pget -c -n 10 file.dat # use 10 threads download file.dat
lftp -e "get -c BAM_BIG/109121_109121-N_rmdup_realigned_dup.bam ; exit " -u guanjx,guanjx123 124.16.129.97 # command line for lftp

Regrex pattern: for grep
	^ $ . [] : same with perl 
	if grep -E : use ? * + {n} {n,} {n,m}
	See more detail in shell of grep

print lower case with awk

awk 'BEGIN{OFS="\t"}{$1=tolower($1); print $0}' 

## MAGIC AWK ##
awk '$1 ~ /^#/ {print $0;next} { if(!a[$1][$2]++){print $0 }  }' # keep header, remove duplication, one line
awk '$1 ~ /^#/ {print $0;next} {print $0 | "LC_ALL=C sort -k1V,1 -k2n,2"}' # keep header, sort all others as chr, pos

Extend of parameters
		for i in 1 2
		do
			function ${i}_tmp     # different with $(($i+1))
		done

    tail -f : append display
    watch -n 2 : doing circle

# Real example for shell script
ls *.sam| xargs -i echo "perl -ane '{next if (/^\@SQ/);next if(\$F[2] eq "*");\$F[2]=\$F[2]."_validated";{print join(\"\\t\",@F),\"\\n\"}}'" "/share/disk1-3/Cancer/Solid/Genome/solexa/20100421_S211_FC61GV4AAXX_0001/bwa_result/"{} "| samtools view -buT /share/disk7-3/wuzhygroup/wangy/cancer/new2.fa - |samtools sort -" {}".sort" 
Samtools
	Filter unmap reads:
    samtools  view  -f 0x04 -hb /media/yulywang/LaCie/data/mutiregion-2_novogene_1400108_153713/152620T1_152620T1_rmdup_realigned.bam > /tmp/escc/152620T1.unmap.1.bam

# special script for read chromosome and others
for file in /share/disk7-3/wuzhygroup/ruanjue/genomes/hg18/chr*.fa
do
    short1=${file##/share/disk7-3/wuzhygroup/ruanjue/genomes/hg18/}
    short2=${short1%%.fa}
    echo $short1
    echo $short2
done

Read File: 
while read line; do echo -e "$line"; done < ~/db/human/chr.list
while read line; do    
	   echo $line    
done < file.txt

# after filter , replace first and second column with chr and pos
perl -ane '{my @a = grep {$F[$_] =~ /chr/} (0..$#F); $F[0] = $F[$a[0]]; $F[1] = $F[$a[0]+1]; $F[2] = $F[$a[0]+2]; print join("\t",@F),"\n"; }'

Pipe or Fifo (mkfifo 1 2 )
HCC1_N0="pileup_inf_rj.pl HCC1-N0.pileup "
HCC1_N1="pileup_inf_rj.pl HCC1-N1.pileup "
bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 <($HCC1_N0) <($HCC1_N1)" | perl -ane '{my @a = grep {$F[$_] =~ /chr/} (0..$#F); $F[0] = $F[$a[0]]; $F[1] = $F[$a[0]+1]; $F[2] = $F[$a[0]+2]; print join("\t",@F),"\n"; }' > 1 &

run.sh
i=37
while((i<41))
	do
echo $i
	sh $i."sh" &
	i=$((i+1))
	done

    as.numeric(as.character remove non-numeric

    VIM
    substitute \s+ to \n : %s/\s\+/\r/g

    awk '!x[$0]++' source target # output first apprearnce
DATA=`awk '/^_DATA_/ {print NR + 1; exit 0; }' "$0"`;
awk -v line=$DATA 'NR>=line' "$0" > a.awk;

exit 0;
_DATA_
#!/usr/bin/awk -f
function abs(x) {
  return (((x < 0) ? -x : x) + 0);
}
{if (abs($9)>=100 && abs($9)<=10000 && $5>=10 ) {print $0} }


vlookup{search item, database(first column must be search items), return which colunms, 0/1)
=ARRAYFORMULA(vlookup($A2,'Only FMD Aneu Diss'!B:BK,{2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62},false))
Ref: https://www.benlcollins.com/formula-examples/vlookup-return-multiple-columns/
# tar scp
tar -zcf - */sequence.txt | ssh 192.168.1.122 tar -xzf - -C /home/wangy/wangy
tar -N '2019-02-01 00:00:00' -jcvf ~/turbo/FMD.190201_190717.tar . # tar any files newer than 190717 and create
tar --newer-mtime '2019-02-01' -jcf ~/turbo/FMD.190201_190717.tar . # this works at currenct cluster,should double check which one works better

hg18 CDS 33266218
hg19 CDS 33112608
SRA download:
#~/wangy/.aspera/connect/bin/ascp -Q -l10M -k 2 -i ~/wangy/.aspera/connect/etc/asperaweb_id_dsa.putty anonftp@ftp-private.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/SRR166/SRR166831/SRR166831.sra .
PCA analysis for R: http://www.statmethods.net/advstats/factor.html

R-ARGV
args <- commandArgs(trailingOnly = TRUE)
args <- as.numeric(args)

tab[[1]]["Total",]<-temp # anova result, for speciall data.frame

Qsub login
first qsub -I -q bioque
then ssh some node

samtools bcftools --- pipeline
samtools mpileup -BIuf $REF_Human 1.sort.bam 2>> $PREFIX.log | bcftools view -bvgce - > $PREFIX.raw.bcf
bcftools view -I $PREFIX.raw.bcf | vcfutils.pl varFilter -d10 -D100 -w 20 -W 20 | grep -v ^# | rmAdjError.pl -d 10 - | awk '$6>=20 '''
# detect which cluster is Open
nmap -sV -p 22 192.168.50.1-255

Graph: 
Combine graph: montage
montage -geometry +5+5 Pheatmap_from_multiplication.png Pheatmap_from_raw.png Pheatmap_from_raw_with_normal.png heatmap.png
/usr/bin/montage -geometry 1500X1500+3+3
PDF2png:
pdftopng='pdftoppm -png -rx 300 -ry 300'
bcftools query: bcftools query -f "%CHROM\t%POS\t%INFO/AC\t GT\t[%GT\t]\n"

IGV:
cat list| uniq | awk '{print $2"\t"$3"\t"$1}' | perl -ane '{print "new\nload G:\\FMD_FLUX_BACKUP_20181023\\bam\\Sort.Dup.BQ\\$F[2].sort.dup.bq.bam\nsnapshotDirectory G:\\\ngoto chr$F[0]:$F[1]-$F[1]\nsort strand\ncollapse\nsnapshot $F[2]_$F[0]_$F[1].png\n"}'  > IGV.batch # input format: id/chr/pos

Shell to STAR
fq1=$1
fq2=$2
prefix=$3
short_prefix=${prefix##*/}
short_prefix="ID:${short_prefix}"
STAR --runMode alignReads \
--readFilesIn ${fq1} ${fq2} \
--outFileNamePrefix	${prefix} \
--outSAMattrRGline ${short_prefix} \
--genomeDir	/nfs/turbo/umms-sganesh/yulywang/FMD/RNASeq/db/STAR_hg19_Index \
--sjdbGTFfile /nfs/turbo/umms-sganesh/yulywang/FMD/RNASeq/db/gencode.v19.annotation.gtf \

Print 000 001
seq 1 311 | xargs printf "%03d\n" {}
Get full path file: readlink -f
make -k -f skat.Makefile # k: continue, f filename

Select only 2nt indels: bcftools view -i 'abs(strlen(ALT)-strlen(REF))<=2'
	The key for annovar indel is: both ref and del should have allele bases, Checking ucsc genome browser to add it 
