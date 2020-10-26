#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:trans.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 13 Nov 2018 12:02:38 PM EST
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
	my @F = split/-/,$line;
	if($F[1]<10){
		$F[1] = "000".$F[1];
	}
	elsif($F[1]<100){
		$F[1] = "00".$F[1];
	}
	elsif($F[1]<1000){
		$F[1] = "0".$F[1];
	}
	print $F[0]."-".$F[1],"\n";
}
