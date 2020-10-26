#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@gmail.com>
#
use strict;
use warnings;
require "fisher_exact_test.pl";

while(my $line = <>){
	my @tabs = split /\s/, $line;
	next if($tabs[12] < 8 or $tabs[20] < 8);
	my @matrix = ([$tabs[12] * $tabs[15], $tabs[12] * $tabs[16], $tabs[12] * $tabs[17], $tabs[12] * $tabs[18]],
		[$tabs[12] * $tabs[23], $tabs[12] * $tabs[24], $tabs[12] * $tabs[25], $tabs[12] * $tabs[26]]);
	my $p = fisher_exact_test(\@matrix);
	my $str = join("\t", map {join("\t", @$_)} @matrix);
	print "$str\t$p\n"; 
}
