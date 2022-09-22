#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:print.pl  -h
#        DESCRIPTION: -h : Display this help [Input Gzip list]
#        Format of gzip: 
#        /nfs/turbo/umms-sganesh/yulywang/FMD/SNVCalling_2019/Fastq/AD113_R1.fastq.gz
#        Will change R1 to R2 and infer the prefix automatically
#        Original resource from WES2018 Pipeline: FMD/SNVCalling/pipeline/StepOne.bwa.pl
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 18 Apr 2018 10:35:15 PM EDT
#        Updated Time: 12/16/2019
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $i = 0;
while(my $input = <>){
	chomp $input;
	my $gz1 = $input;
	my $gz2 = $gz1;
	$gz2 =~ s/R1.fastq.gz$/R2.fastq.gz/;

	my @F = split/\//,$input;
	my $prefix = $F[$#F];
	$prefix =~ s/_R1.fastq.gz$//;
	my $dir = join("\/",@F[0..($#F-1)]);
	#print "$gz1\t$gz2\t$prefix\n";

	my $header = "\@RG\\tID:$prefix\\tPL:Illumina\\tLB:$prefix\\tDS:pe::0\\tDT:2021-06-02\\tSM:$prefix\\tCN:U_Michigan_YuWang_Ganesh_Lab";

	$prefix = $dir."/".$prefix; # update prefix to full path
	print "bwa7.17 mem -R \"$header\" -t 4 -k 20 -w 105 -d 105 -r 1.3 -c 12000 -A 1 -B 4 -O 6 -E 1 -L 6 -U 18 /home/yulywang/db/human/hs37d5 $gz1 $gz2 | gzip -3 > $prefix.sam.gz; "; # bwa mem -p is disable
	print "gzip -dc $prefix.sam.gz | samtools view --threads 4 -b1ht /home/yulywang/db/human/hs37d5.fa.fai - > $prefix.unsort.bam;";
	print "samtools sort -m 1600M --threads 4 -O BAM -o $prefix.sort.bam $prefix.unsort.bam;"; 
	print "samtools index $prefix.sort.bam;";
	print "rm $prefix.sam.gz; rm $prefix.unsort.bam; ";
	$i++;
	if($i % 1 == 0 ){ # this will merge 30 samples as one command line
			print "\n";
	}
	#print "\n";
}
