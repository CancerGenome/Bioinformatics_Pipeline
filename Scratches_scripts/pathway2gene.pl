#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/pathway2gene.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Given a GSEA pathway, output
#        Gene, their affiliated pathway, separate by comma
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 26 Nov 2019 10:05:00 AM EST
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
	my @F = split/\s+/,$line;
	for my $f(2..$#F){
		if (not exists($hash{$F[$f]})){
			$hash{$F[$f]} = $F[0];
		}else{
			$hash{$F[$f]}  = $hash{$F[$f]}.",".$F[0];
		}
	}
}

for my $key (keys %hash){
	print $key,"\t",$hash{$key},"\n";
}
