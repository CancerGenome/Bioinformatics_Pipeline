#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  get piRNA reads number
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  06/29/2009 04:29:42 PM
#===============================================================================

use strict;
use warnings;

$ARGV[1]|| die "\t\tPerl $0 <Clean.fas> <Blast_filter_file>\t\n";
my %hash;
open IN,$ARGV[0]; # defalt clean.fas
while(<IN>){
	chomp;
	if (/>/) {
		s/>//isg;
	split;
#print $_[0],"\n";
	$hash{$_[0]} = $_[1];
	}

}


open B,$ARGV[1];
while(<B>){
	chomp;
	split;
	$_[$#_+1]= $hash{$_[0]};
	print join ("\t",@_),"\n";
}



