#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  06/02/2009 03:16:41 PM
#===============================================================================

use strict;
use warnings;

while(<STDIN>){
	chomp;
	split;
	my $pos_r = $_[3]-1;
	my $chr = $_[2];
	my @read = split//,$_[9];
	next if ($_[6] eq "*");
	if (/MD:Z:([0-9]+)(.+)/){
		my $pos =$1;
		$_ = $2;
		my @array =m/([AGCTN]|\^[AGCTN]+)([0-9]+)/g;
		foreach my $now (@array){
			if ($now =~/[0-9]+/) {$pos+=$now;}
			elsif ($now =~/\^[AGCTN]+/) {$pos = $pos +length($now)-1;}
			elsif ($now =~/[AGCTN]/) {$pos++; my $pos_now = $pos_r+$pos; print "$chr\t$pos_now\t$now\t$read[$pos-1]\n";}
		}
	}

}

