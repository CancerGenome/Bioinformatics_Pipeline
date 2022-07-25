#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./hash.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  06/08/2009 01:44:19 PM
#===============================================================================

use strict;
use warnings;

my %hash;
while(<>){
	chomp;
	my $null = (exists $hash{$_}) ?($hash{$_}++) : ($hash{$_}=1);
}
foreach my $key (sort keys %hash){
	print "$key\t$hash{$key}\n";
}

