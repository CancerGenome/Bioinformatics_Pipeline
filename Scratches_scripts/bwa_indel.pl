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
#      CREATED:  05/18/2009 09:32:20 PM
#===============================================================================

use strict;
#use warnings;
$ARGV[0]||die "\t\t$0 <INPUT> \n\t\tPrint all indel in bwa sam file\n";
while(<>){
chomp;
split;
next if ($_[5] eq "*");
#if ($_[5] =~ /([0-9]+[MIDNSHP])+/ ){
#	print $2,"\n";
#}
$_ =$_[5];
my @array =m/([0-9]+[MIDNSHP])/g;
my $count=0;
foreach my $num (@array){
if ($num =~ /([0-9]+)([MIDNSHP])/){
	if ($2 eq "D" || $2 eq "I"){
		my $cache = $_[3] + $count;
		print "$_[2]\t$cache\t$1\t$2\n";
	}
	
	$count += $1;
}
}
}
