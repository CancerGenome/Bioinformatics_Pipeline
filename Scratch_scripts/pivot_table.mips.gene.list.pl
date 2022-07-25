#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/pivot_table.mips.gene.list.pl  -h
#        DESCRIPTION: -h : Display this help
#        Given a gene list, print pathway and gene
#        Follow by trans_statsV4.pl
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 27 Jul 2020 10:36:42 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my %gene;

my $j = 1;
while (my $line = <>){
    chomp $line;
    my @F = split/\s+/,$line;
	for my $i(1..$#F){
		print "$F[$i]\t$j\_$F[0]\n";
	}
	$j++;
}

