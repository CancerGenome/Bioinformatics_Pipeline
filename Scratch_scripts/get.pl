#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./get.pl  
#
#  DESCRIPTION:  This program translate gff file to commom readable file
#				 This file input have three addition columes at head, so handle your file first
#				 This input was created from select_from_gff.pl 			
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/23/2009 
#===============================================================================

		  )
}
use strict;
use warnings;
#$ARGV[0] || &usage();
my $last = 3607162;
while(<>){
	chomp;
	split;
#if ($_[1] != $last){print "$_[1]\n$_[1]\n";}
	if ($_[1] != $last){print "$_[1]\n";}
	print "$_[1]\t\t";
	my $tag= $_[9];
	if (/solid/){
		print "$_[6]\t\t$_[7]\t\t";	
	}
	if (/EAS/){
		print "$_[5]\t\t$_[5]\t\t";
	}
	if (/s=(.*);/){
		print "$tag\t";
		my $a = $1;
		$a =~s/s=//;
#---- Print all snp
#---- validate single snp
		if ($a=~/g(\d+),g(\d+)/){
				if ($tag eq "+"){
					my $cache = $_[6]+$1-1;
					print "$cache";
				}
				elsif ($tag eq "-"){
					my $cache = $_[7]-$1+1;
					print "$cache";
				}
			}	
#---- validated double snp
		elsif ($a=~/y(\d+),y(\d+),y(\d+)/){
				if ($tag eq "+"){
					my $cache = $_[6]+$1;
					print "$cache\_";
					$cache = $_[6]+$2;
					print "$cache";
				}
				elsif ($tag eq "-"){
					my $cache = $_[7]+1-$1;
					print "$cache\_";
					$cache = $_[7]+1-$2;
					print "$cache";
				}
			}	
#---- validate three snp
		elsif($a=~/r(\d+),r(\d+),r(\d+),r(\d+)/){
				if ($tag eq "+"){
					my $cache = $_[6]+$1;
					print "$cache\_";
					$cache = $_[6]+$2;
					print "$cache\_";
					$cache = $_[6]+$3;
					print "$cache";
				}
				elsif ($tag eq "-"){
					my $cache = $_[7]+1-$1;
					print "$cache\_";
					$cache = $_[7]+1-$2;
					print "$cache\_";
					$cache = $_[7]+1-$3;
					print "$cache";
				}
			}	
		else {
			print "-\t";
		}
		print "\t",$a,"\t";
		
#	if (/r=(.*?);/){
#		print $1,"\t";
#	}
	if (/g=(.*?);/){
		print "\t",$1;
	}
	}
	else {print "-\t-\t-\t";}
	if (/MD:Z:(.*)/){
		print $1;
	}
 $last= $_[1];

	print "\n";
}
