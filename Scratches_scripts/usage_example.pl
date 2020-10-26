#!/usr/bin/perl 
sub usage(){
	print qq(
#===============================================================================
#
#        USAGE:  ./tri.pl  
#
#  DESCRIPTION:  Use to display per three add comma    
#                Eg, 10000 -> 10,000
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  08/23/2009 06:22:57 PM
#===============================================================================
		  )
}
use strict;
use warnings;

if ($ARGV[0] eq "-h" or $ARGV[0] eq "help" or $ARGV[0] eq "--h" ){&usage;exit;}
$ARGV[0]|| &usage;

while(<>){
	s/(\d+)/$1,/g;
	print;
}

