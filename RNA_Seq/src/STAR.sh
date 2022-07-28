#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: STAR.sh FQ1 FQ2 Sample_ID
#      Description:
#      Example: 
#      STAR.sh  FASTQ/109_A2_R1_001.fastq.gz    FASTQ/109_A2_R2_001.fastq.gz    FASTQ/109_A2
#
#      Update note: update header of bam file, 02/21/2021
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 01 Nov 2019 04:48:25 PM EDT
#########################################################################
"
exit
fi
fq1=$1
fq2=$2
prefix=$3
short_prefix=${prefix##*/}
echo -e '@CO\tREFID:Homo_sapiens_assembly19\n@CO\tANNID:gencode.v19' > $prefix\_comments.txt
echo $short_prefix | perl -ane '{print "\@RG\tID:$F[0]\tLB:$F[0]\tPL:Illumina\tSM:$F[0]\tPU:unit1\tCN:UofM_YuWang_Ganesh_Lab\n"}' - >> $prefix\_comments.txt
short_prefix="ID:${short_prefix} SM:${short_prefix}"
echo $fq1,$fq2,$prefix,$short_prefix
#:<<'BLOCK'
STAR --runMode alignReads \
--readFilesIn ${fq1} ${fq2} \
--outFileNamePrefix	${prefix} \
--genomeDir	~/FMD/RNASeq/db/STAR_hg19_Index \
--sjdbGTFfile ~/FMD/RNASeq/db/gencode.v19.annotation.gtf \
--runThreadN	8 \
--alignIntronMax	1000000 \
--alignIntronMin	20 \
--alignMatesGapMax	1000000 \
--alignSJDBoverhangMin	1 \
--alignSJoverhangMin	8 \
--alignSoftClipAtReferenceEnds	No \
--chimJunctionOverhangMin	15 \
--chimMainSegmentMultNmax	1 \
--chimOutType	WithinBAM HardClip \
--chimSegmentMin	15 \
--limitBAMsortRAM	30000000000 \
--limitSjdbInsertNsj	3000000 \
--outFilterMatchNminOverLread	0.33 \
--outFilterMismatchNmax	999 \
--outFilterMismatchNoverLmax	0.1 \
--outFilterMismatchNoverReadLmax	0.07 \
--outFilterMultimapNmax	20 \
--outFilterScoreMinOverLread	0.33 \
--outFilterType	BySJout \
--outSAMattributes	All \
--outSAMheaderCommentFile	$prefix\_comments.txt \
--outSAMmapqUnique	60 \
--outSAMtype	BAM SortedByCoordinate \
--outSAMunmapped	Within \
--quantMode	TranscriptomeSAM GeneCounts \
--sjdbScore	1 \
--twopassMode	Basic \
--outWigStrand  Stranded \
--readFilesCommand zcat
#BLOCK
