#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./select_from_bam.pl given list as chr1 pos .... 
#
#  DESCRIPTION:  Select from bam file 
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/23/2009 
#===============================================================================

		  )
}
use strict;
use warnings;
$ARGV[0] || &usage();
open OUT1, ">>nor.sel";
open OUT2, ">>rc.sel";
chdir ("/share/disk6-4/wuzhy/wangy/cancer/sam/solexa");
while(<>){
	chomp;
	split;
	my $a  = $_[1]+1;
	my @a = `samtools view nor.$_[0].solexa.mate.bam  $_[0]:$_[1]-$a `;
	my @b = `samtools view rc.$_[0].solexa.mate.bam  $_[0]:$_[1]-$a `;
	foreach $a (@a){
		print OUT1 "$_[0]\t$_[1]\t$a";
	}
	foreach $a (@b){
		print OUT2 "$_[0]\t$_[1]\t$a";
	}
}
