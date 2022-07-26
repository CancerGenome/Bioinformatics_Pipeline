#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  -h
#        DESCRIPTION: -h : Display this help
#
#        I plan to call the SNV based on WES 2019 and MGI controls only because: ( starting from CombineGVCF 24.vcf to 40.vcf)
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 07 Jun 2018 02:00:30 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my $cmd1 = <DATA>;
chomp ($cmd1);

# . I plan to call the SNV based on WES 2019 and MGI controls only because: ( starting from CombineGVCF 24.vcf to 40.vcf)
open IN,"/home/yulywang/db/human/hs37d5.fa.fai";
my $i = 0;
while(my $line=<IN>){
	$i++;
	next if($i>25); # only 1-22, X, Y , MT
	chomp $line;
	my @F = split/\s+/,$line;
	my $chr = $F[0];
	my $start = 1; 
	my $end = $F[1];
	my $step = 30000000;
	if($end <= $step){
		print "$cmd1 -O ../CombineGVCF/$chr\_$start\_$end.g.vcf.gz -L $chr:$start-$end\n";
		next;
	}
	while($start < $end){
		my $stop = $start + $step;
		$stop = $end if ($end < $stop);
		print "$cmd1 -O ../CombineGVCF/$chr\_$start\_$stop.g.vcf.gz -L $chr:$start-$stop\n";
		$start = $start + $step;
	}
		#print "bcftools mpileup -f /home/yulywang/db/human/hs37d5.fa -b bam.list -r $F[0]:1-$F[1]| bcftools call -mv -Ob -o $F[0]_1_$F[1].bcf\n";
}

# for this batch, wee only use WES 2019 toghter
__DATA__
gatk4.0.5 CombineGVCFs -R /home/yulywang/db/human/hs37d5.fa -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/24.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/25.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/26.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/27.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/28.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/29.vcf.gz -V ../CombineGVCF/30samples/30.vcf.gz -V ../CombineGVCF/30samples/31.vcf.gz -V ../CombineGVCF/30samples/32.vcf.gz -V ../CombineGVCF/30samples/33.vcf.gz -V ../CombineGVCF/30samples/34.vcf.gz -V ../CombineGVCF/30samples/35.vcf.gz -V ../CombineGVCF/30samples/36.vcf.gz -V ../CombineGVCF/30samples/37.vcf.gz -V ../CombineGVCF/30samples/38.vcf.gz -V ../CombineGVCF/30samples/39.vcf.gz -V ../CombineGVCF/30samples/40.vcf.gz
