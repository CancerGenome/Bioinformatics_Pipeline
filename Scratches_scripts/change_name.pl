#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  change name 
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  05/03/2009 06:11:45 PM
#===============================================================================

use strict;
#use warnings;
$ARGV[1]|| die "Input NAME and PH\n";
open IN,"$ARGV[0]";
my @array;
my %hash;
while(my $line=<IN>){
	$line =~ s/\|/_/isg;
	if ($line =~ /(gi_(\d+)_gb\_.+\_)\s+(.+)\n/){
		push (@array,$1);
		my $cache = $2;
		$cache .="_".$3;
		$hash{$1}= $cache;
	}

}
#print "ARRAY @array\n";
open IN2, "$ARGV[1]";
while(my $line=<IN2>){
	chomp $line;
 	next if ($line eq "");
	$line =~ s/\|/_/isg;
	foreach my $now (@array){
#	print "NOW:$now\n";
	if ($line =~ $now)	{
		$line =~ s/$now/$hash{$now}/isg;
#	print $line ,"\t", $hash{$now},"\n";
	}
	
	}
		print "$line\n";

}



