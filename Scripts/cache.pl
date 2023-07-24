#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./rc.chr11.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:   , 
#    INSTITUTE:  
#      CREATED:  09/07/2009 
#===============================================================================

#}
use strict;
use warnings;
open (IN,"uniq/rc.chr11.uniq")||die "Cannot open the file";
my %hash;
while(my $line=<IN>){
	my @temp;
	my @temp2;
	my $str="";
	@temp=split(/\s+/,$line);
	@temp2=split(/:/,$temp[0]);
	if(($temp[6] eq "=")&&($temp[8]==0)){
		if($temp[1]==137){
			$str=$temp2[0].".read1.fa";
			$hash{$temp[0]}=$str;
		}
		if($temp[1]==73){
			$str=$temp2[0].".read1.fa";
			$hash{$temp[0]}=$str;
		}
		if($temp[1]==153){
			$str=$temp2[0]."read2.fa";
			$hash{$temp[0]}=$str;
		}
		if($temp[1]==89){
			$str=$temp2[0]."read2.fa";
			$hash{$temp[0]}=$str;
		}
	}
}
close IN;
print "ok","\n";
open (IN,"fa/rc1.read1.fa")||die "Can not open the file";
while(my $line=<IN>){
	my $str="";
	my @temp=split(/:/,$line);
	my @temp2=split(/\//,$temp[1]);
	$str="rc1".":".$temp2[0];
	$line=<IN>;
	if(exists $hash{$str}){print $line;}
	$line=<IN>;
	$line=<IN>;
}
