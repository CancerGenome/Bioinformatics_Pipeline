#!/usr/bin/perl  -w 
sub usage(){
	die qq(
#===============================================================================
#
#        USAGE:  ./hash.pl  -i <input>
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#      COPYRIGHT:  
#      VERSION:  1.0
#      CREATED:  07/26/2010 04:17:44 PM
#===============================================================================
)}

use strict;
use Getopt::Std;

our ($opt_i,$opt_h);
getopts("i:h"); # thus can get argument for i and boolen for h
&usage if ($opt_h);
&usage unless ($opt_i);

my %hash;
open IN, "$opt_i";
while(<IN>){
	chomp;
	$hash{$_} ++;
}

my ($a,$b) = qw{0 0};

foreach my $keys (keys %hash) {
	if ($hash{$keys} > 1) {
		$b ++;
	}
	elsif ($hash{$keys} == 1) {
		$a ++;
	}

} 

print "Equal one is $a\n Bigger than one is $b\n";
