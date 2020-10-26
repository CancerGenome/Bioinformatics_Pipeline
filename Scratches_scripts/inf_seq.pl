#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./inf_seq.pl  
#
#  DESCRIPTION:  To isolate influenza by different part
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  05/03/2009 10:13:38 PM
#===============================================================================

use strict;
#use warnings;

my @array = qw(PB2 PB1 PA HA NP NA MP NS);
my $last;
while (<>){
chomp;
my $line = $_;
if ($line =~ /[AGCTN]+/){
	open OUT, ">>$last";
	print OUT  "$line\n";
	close OUT;

}

elsif ($line =~ /^>gi/){
	$last = "";
foreach my $array (@array){
if ($line =~ /$array/) {
	open OUT , ">> $array";
	print "HANDLE: $array\n";
	print OUT "$line\n";
	close OUT;
	$last = $array;   # record which OUT file is open 
	}

}
}

}
