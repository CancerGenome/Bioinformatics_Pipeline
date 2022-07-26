#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  -h
#        DESCRIPTION: -h : Display this help
#        CAVEAT: perl StepSix_GenotypeGVCF.pl - | sed 's/1-30000001/1-30000000/;s/30000001-60000001/30000001-60000000/;s/60000001-90000001/60000001-90000000/;s/90000001-120000001/90000001-120000000/;s/120000001-150000001/120000001-150000000/;s/150000001-180000001/150000001-180000000/;s/180000001-210000001/180000001-210000000/;s/210000001-240000001/210000001-240000000/'
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
my $cmd1 = "/home/yulywang/bin/gatk4.0.5 GenotypeGVCFs -R /home/yulywang/db/human/hs37d5.fa --dbsnp /home/yulywang/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz";

open IN,"/home/yulywang/db/human/hs37d5.fa.fai";
my $i = 0;
while(my $line=<IN>){
	$i++;
	next if($i>25);
	chomp $line;
	my @F = split/\s+/,$line;
	my $chr = $F[0];
	my $start = 1; 
	my $end = $F[1];
	my $step = 30000000;
	if($end <= $step){
		print "$cmd1 -V ../CombineGVCF/$chr\_$start\_$end.g.vcf.gz -O ../GenotypeGVCF/$chr\_$start\_$end.vcf.gz -L $chr:$start-$end\n";
		next;
	}
	while($start < $end){
		my $stop = $start + $step;
		$stop = $end if ($end < $stop);
		print "$cmd1 -V  ../CombineGVCF/$chr\_$start\_$stop.g.vcf.gz -O ../GenotypeGVCF/$chr\_$start\_$stop.vcf.gz -L $chr:$start-$stop\n";
		$start = $start + $step;
	}
}
