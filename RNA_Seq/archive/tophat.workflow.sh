#!/bin/bash
set -x

#----- Read File: fq/gz/bam, processing prefix name
#sleep 30
DIR="./"
LOG="$DIR/workflow.log"
REF_Human="$DIR/ref/ref.fa"
GTF="$DIR/ref/Homo_sapiens.GRCh37.75.gtf"

REF_Mac="$DIR/ref/rheMac3.fa"
GTF_Mac="$DIR/ref/Macaca_mulatta.MMUL_1.78.gtf"

EXPORT="$DIR/export_file.list"
FINISH="$DIR/output/FINISH"

TOPHAT=tophat
SAMTOOLS=samtools
CUFFLINKS=cufflinks
CUFFMERGE=cuffmerge
CUFFQUANT=cuffquant
CUFFDIFF=cuffdiff
#CPUNum=`grep processor /proc/cpuinfo | awk '{print $3}'| tail -n1`
CPUNum=3;

function bak_rotate()
{
  for i in diff_out/*tracking; do
	  mv -f $i.1 $i.2
	  mv -f $i $i.1
  done

  mv -f merged_asm/merged.gtf.1 merged_asm/merged.gtf.2
  mv -f merged_asm/merged.gtf merged_asm/merged.gtf.1
}

# clean up
rm -f $FINISH $DIR/bamlist.txt $DIR/assemblies.txt $DIR/cxblist.txt $DIR/summary.stat

# prestart
dos2unix $DIR/sample.txt ## sample should be ordered by time series
cd $DIR
bak_rotate

# start
echo "Start working at `date`" > $LOG

#----- Map the reads for each sample to the reference genome, test whether have pair end file
for arg in `cat $DIR/sample.txt | sed 's/,/\n/g' `
do
	echo "Reading File " $arg >> $LOG
	surffix=${arg##*/}
	label=`echo $surffix| cut -f1 -d "."`
	#echo $label  >> $DIR/label.txt #label should be prepared as input

	PREFIX=$DIR/output/$surffix
	echo "Processing File " $PREFIX >> $LOG
	FQ=$arg
	FQ2=`echo $surffix | sed 's/_1/_2/; s/_R1/_R2/'`
	DIRNAME=`dirname $FQ`
	FQ2=$DIRNAME/$FQ2

echo "Data alning starting at `date`" >> $LOG
#:>>BLOCK'
if test -f $FQ2
then
	time $TOPHAT -p $CPUNum -o $PREFIX.tpout $REF_Human $FQ $FQ2 2>> $LOG
else
	time $TOPHAT -p $CPUNum -o $PREFIX.tpout $REF_Human $FQ 2>> $LOG
fi
	echo "Data alning end at `date`" >> $LOG
	echo "File $FQ" >> $DIR/summary.stat
	cat $PREFIX.tpout/align_summary.txt >> $DIR/summary.stat

#----- Assemble Transcripts for Each Sample
	time $CUFFLINKS -p $CPUNum -o $PREFIX.clout $PREFIX.tpout/accepted_hits.bam 2>> $LOG
	echo $PREFIX.tpout/accepted_hits.bam >> $DIR/bamlist.txt
	ls $PREFIX.clout/transcripts.gtf >> $DIR/assemblies.txt
done

echo "Finishing Mapping & Transcripts Assemble Jobs at `date`" >> $LOG

#----- Merged Transcriptome Annotation
	time $CUFFMERGE -g $GTF -s $REF_Human -p $CPUNum $DIR/assemblies.txt
	echo "Finishing Annotation Merge Jobs at `date`" >> $LOG

#----- Quantification for each transcript
for arg in `cat $DIR/bamlist.txt `
do
	echo "BAM File " $arg "deliver" >> $LOG
	surffix=${arg%/*}
	surffix=${surffix##*/}
	surffix=`echo $surffix| sed 's/.tpout//'`
	PREFIX=$DIR/output/$surffix
	time $CUFFQUANT -o $PREFIX.cqout -p $CPUNum merged_asm/merged.gtf $arg 2>> $LOG
	echo "Finishing Quant Jobs at `date`" >> $LOG
done
#	echo $PREFIX.cqout/abundances.cxb >> $DIR/cxblist.txt
perl -ne '{chomp $_; while($_=~/(.+?)\/(.+?)\,/g){print "output/",$2,".cqout/abundances.cxb,"} print "\n" }' sample.list  | sed 's/,$//' > cxblist.txt
#:BLOCK'
#----- Identify Differentially Expressed Genes and Transcripts
	CXB_LIST=`cat cxblist.txt|tr '\n' ' '`
	LABEL=`cat label.txt|tr '\n' ','`
	time $CUFFDIFF -o diff_out --no-diff -b $REF_Human -L $LABEL -p $CPUNum -u merged_asm/merged.gtf $CXB_LIST 2>> $LOG

echo "Finishing Diff Jobs at `date`" >> $LOG
#----- Visualization differential analysis results with CummeRbund

touch $FINISH
