#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./read_qv.pl  
#
#  DESCRIPTION:  To store all qv in hash
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  03/30/2009 03:05:13 PM
#===============================================================================

use strict;
use warnings;

my %hash;
my $line;
while (my $id = <>){
	if ($id =~/^>/)  {
	$line = <>;	
	my @array = split/\s+/,$line;
 	@{$hash{$id}}= @array;
	}    
}
        

