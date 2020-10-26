#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./quick mapping -i "Regrex of fq file" -d "diretory of output" -c "use hg19" -q "do not qsub" -m
#
#  DESCRIPTION: Quick mapping with bwa pipeline with hg18
#               -m : use mouse mapping
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/22/2011 
#===============================================================================

)
}
use strict;
use warnings;

use Getopt::Std;
our($opt_i,$opt_d,$opt_c,$opt_q,$opt_m);
getopts("i:d:cqm");
&usage() if (not defined $opt_i);
if (not defined $opt_d) {
    $opt_d = ".";
}

my @a = `ls $opt_i`;
chomp @a;
#my @b = `less qsub.sh`;

my @cache = <DATA>;
foreach(@a) {
#    my @file = (split/\//,$_);
#    my $file = pop(@file);
    open OUT,">$_.sh";
    select OUT;
    print "FILE=$_\n";
    print "PREFIX=$opt_d\n";
    my $file2 = $_;
#    $file2 =~ s/_1_/_2_/ ;
    $file2 =~ s/_1/_2/ ;
    $file2 = "None" if ($_ eq $file2);
    print "FILE2=$file2\n";
    print @cache,"\n\n";
    print "cp $_.sh $opt_d\n";

    close OUT;
    if (defined $opt_c) {
       ` sed -i 's/hg18/hg19/g' $_.sh ` ;
    }
    if (defined $opt_m) {
       ` sed -i 's/hg18/mm9/g' $_.sh ` ;
    }
    `qsub.pl -t10 -n4 -m8 $_.sh` if (not defined $opt_q);
}

__DATA__

SHORT=${FILE%.fastq}
SHORT=${FILE%.fq}
SHORT=${FILE%.fa}
SHORT=${SHORT%.fq.gz}
SHORT=${SHORT%.fa.gz}
SHORT=${SHORT%.txt.gz}
SHORT2=${FILE2%.fq}
SHORT2=${FILE2%.fa}
SHORT2=${SHORT2%.fq.gz}
SHORT2=${SHORT2%.fa.gz}
SHORT2=${SHORT2%.txt.gz}
SHORT2=${SHORT2%.trim.fq}
FINAL=$SHORT

## bwa aln 
echo $FILE
echo "Data alning starting at `date`"
bwa aln -t 8  ~/db/human/hg18 $FILE > $PREFIX/$SHORT.aln

echo "Bam file starting at `date`"

if test -f $FILE2
then 
bwa aln -t 4  ~/db/human/hg18 $FILE2 > $PREFIX/$SHORT2.aln
bwa sampe ~/db/human/hg18 $PREFIX/$SHORT.aln  $PREFIX/$SHORT2.aln  $FILE $FILE2 | samtools view -bt ~/db/human/hg18.fa.fai -T ~/db/human/hg18.fa - > $PREFIX/$FINAL.bam
else
bwa samse ~/db/human/hg18 $PREFIX/$SHORT.aln $FILE | samtools view -bt ~/db/human/hg18.fa.fai -T ~/db/human/hg18.fa - > $PREFIX/$FINAL.bam
fi
samtools sort $PREFIX/$FINAL.bam $PREFIX/$FINAL.sort
samtools index $PREFIX/$FINAL.sort.bam 

:<<'BLOCK'
samtools rmdup $PREFIX/$FINAL.sort.bam $PREFIX/$FINAL.rmdup.bam
samtools index $PREFIX/$FINAL.rmdup.bam 

echo "Statistics process starting at `date`"
samtools pileup -f ~/db/human/hg18.fa  $PREFIX/$FINAL.sort.bam |cut -f1-4 | genoann -d ~/db/anno/hg18.map | quniq.pl -c '4;4,5' - > $PREFIX/$FINAL.stat

awk '$1=="A"' $PREFIX/$FINAL.stat | awk '{a+=($2*$3)}END{print "Total Coverage is " a }' >> $PREFIX/$FINAL.map.summary
Total_map=`awk '{if ($1=="A") {a+= ($3*$2) } } END {print a}' $PREFIX/$FINAL.stat `
awk '$1=="A"' $PREFIX/$FINAL.stat | sort -k2n,2 | head -10  >> $PREFIX/$FINAL.map.summary
echo "" >> $PREFIX/$FINAL.map.summary

awk '$1=="A"' $PREFIX/$FINAL.stat | awk '{a+=($2*$3);b+=$3}END{print "Total Site Cover Region is " b " Total site Average Depth is "a/b}' >> $PREFIX/$FINAL.map.summary
echo "" >> $PREFIX/$FINAL.map.summary

awk -v Total_map=$Total_map '{ if($1=="B" && $3=="CDS") {a+= ($2 * $4); b+=$4 }} END {print "CDS Coverage is " a " CDS Cover Region is " b ", And CDS rate/Total map reads=" a/Total_map," ,CDS Average Depth "a/b} ' $PREFIX/$FINAL.stat  >> $PREFIX/$FINAL.map.summary
echo "" >> $PREFIX/$FINAL.map.summary

awk -v Total_map=$Total_map '{ if($1=="B" && $3!="INTERGENIC") {a+= ($2 * $4); b+=$4 }} END {print "Non-Intergenic Coverage is " a " CDS Cover Region is " b ", And Non-Intergenic rate/Total map reads=" a/Total_map," ,Non-Intergenic Average Depth "a/b} ' $PREFIX/$FINAL.stat  >> $PREFIX/$FINAL.map.summary

BLOCK
