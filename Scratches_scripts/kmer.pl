#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./kmer.pl  
#
#  DESCRIPTION:  Use to statis 17kmer depth
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  05/05/2009 03:58:53 PM
#===============================================================================

use strict;
use warnings;

my $tcount=0;
my %hash;

while(<>){
	chomp;
 	if (/@/){
	my $line = <>;
	chomp $line;
	my $length = length($line);
	for my $i (0..($length-17)){
	my $input = substr($line,$i,17);
	my $null = exists ($hash{$input}) ? ($hash{$input}++):($hash{$input}=1);
	}
	}	
	
}

foreach my $key (keys %hash){
print "$key\t $hash{$key}\n";
}
