#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/junzli_lab/yulywang/bin/print_seg_genome.pl  -h
#        DESCRIPTION: -h : Display this help
#                          Used for generating of intervals of vcf files
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 25 Aug 2016 03:37:52 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

while(<>){
	chomp;
	my @F = split/:/,$_;
	my @G = split/-/,$F[1];
	my $i = int($G[1]/1000000);
	for my $j(0..$i){
		if($G[1] >= ($j+1)*1000000){
			print $F[0],":",$j *1000000 +1, "-", ($j+1)*1000000,"\n";
		}
		elsif($G[1] < ($j+1)*1000000){
			print $F[0],":",$j *1000000 +1, "-", $G[1],"\n";
		}
	}
}
