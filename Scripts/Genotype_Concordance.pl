#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/Genotype_Concordance.pl  <VCF1> <VCF2> <Sample Corresponding File>
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 18 Feb 2020 05:03:23 PM EST
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
	my @F = split/\s+/;
}

#my %map; # first sample -> second sample 
#
#while(my $line = <DATA>){
#	chomp $line;
#	my @F = split/\s+/,$line;
#	
#}
#
#my %hash;
#while(my $line = <>){
#	chomp $line;
#	my @F = split/\s+/;
#	my %gt;
#
#	foreach my $f(@F){
#		my @G = split/\=/,$f;
#		$gt{$G[0]}  = $G[1];
#	}
#
#	foreach my $key (keys %map){
#		my $gt1 = $gt{$key} || './.';
#		my $gt2 = $gt{$map{$key}} || './.';
#		$hash{$key}{$map{$key}}{$gt1}{$gt2}++;
#	}
#}
#
#
#	foreach my $key (keys %map){
#		print "$hash{$key}{$map{$key}}{'./.'}{'./.'}\n";
#	}
