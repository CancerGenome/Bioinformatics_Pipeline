#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  -h
#        DESCRIPTION: -h : Display this help, Key of first column, output accumulate sum of third column.
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 11 Apr 2019 11:39:46 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my %hash;

while(my $line = <>){
	chomp $line;
	next if($line eq "");
	my @F= split/\s+/,$line;
	$hash{$F[0]} += $F[2];
}

foreach my $key (keys %hash){
	print $key,"\t",$hash{$key},"\n";
}
