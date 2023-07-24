#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Final_filter.pl  -h
#        DESCRIPTION: -h : Display this help
#        Make Annovar result looks clean
#        non syn -> non_syn;
#        exonic;exonic;exonic -> exonic
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  2018年02月13日 星期二 16时16分13秒
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

while(my $line = <>){
	chomp $line;
	my @F = split/\t/,$line;
	# clean column 6,9,10, and use substitution to replace gap;
	my @A = split/;/,$F[5];
	my @B = split/;/,$F[8];
	$B[0] =~s/ /_/g;
	my @C = split/[;,]/,$F[9];
	
	$F[5] = $A[0];
	$F[8] = $B[0];
	$F[9] = $C[0];

	print join("\t",@F),"\n";
}
