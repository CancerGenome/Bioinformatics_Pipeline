#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:format_to_annovar.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 25 Jan 2019 05:14:46 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

print "#Chr\tStart\tEnd\tRef\tAlt\tUMD_Score\tUMD_Pred\n";
while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $effect = "-";
	if($F[7]>=75){
		$effect = "D";
	}elsif($F[7]>=65){
		$effect = "P";
	}elsif($F[7]>=50){
		$effect = "PB";
	}elsif($F[7]>=0){
		$effect = "B";
	}
	print "$F[0]\t$F[1]\t$F[1]\t$F[3]\t$F[4]\t$F[7]\t$effect\n";
}

#1       35150   FAM138A T       A       R       S       72      -
