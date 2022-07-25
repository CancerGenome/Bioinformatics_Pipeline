#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/25/2009 
#===============================================================================

		  )
}
use strict;
use warnings;
open H,"> head.fq";
open T,"> tail.fq";
my $n =0;
while (<>){
	$n ++;
	print H;
	print T;
	my $a = <>;
	print H substr ($a,0,17),"\n";
	print T substr ($a,17,17),"\n";
	$_=<>;print H; print T;
	$a=<>;
	print H substr ($a,0,17),"\n";
	print T substr ($a,17,17),"\n";
	if ($n==10000000) {exit;}
}

