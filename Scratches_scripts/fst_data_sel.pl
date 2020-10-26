#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./fst_data_sel.pl  
#
#  DESCRIPTION:  get data from tiandm file and output fst calculation
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  08/07/2009 03:50:24 PM
#===============================================================================

use strict;
use warnings;
print "#Chr\tPos\tTag\tRef\tBase\tRef_nor\tRef_rc\tSum_nor\tSum_rc\n";
my @file=`more $ARGV[0]`;
my %nor=("A" =>12,"C"=>13,"G"=>14,"T"=>15
		);
my %rc=("A" =>29,"C"=>30,"G"=>31,"T"=>32
		);
my @base=qw(A G C T);
my $dep_min = 4;
my $fre_min = 0.5;
foreach my $file (@file){
	chomp $file;
# get chr from file name
	my ($chr,$ref,$pos,$tag);
	if ($file =~/(chr\S+)_snp[12]/){$chr=$1;}
	open IN,"$file"|| die "Can not open $file\n";
	while(<IN>){
	next if (/#/);
	chomp;
	split;
	$ref = $_[1];
	$pos = $_[0];
	$tag = $_[2];

	my ($sum_nor,$sum_rc); 
	for my $i (12..19){
	 	$sum_nor += $_[$i];	
	}
	for my $i (29..36){
	 	$sum_rc += $_[$i];	
	}
# minus depth <4
	next if ($sum_rc < $dep_min);
	next if ($sum_nor < $dep_min);
# allele freq > 0.5 either
	foreach (@base){
		next if ($_ eq $ref);
	my $cache_nor = $_[$nor{$_}]+ $_[$nor{$_}+4];			
	my $cache_rc = $_[$rc{$_}]+ $_[$rc{$_}+4];			
	if ($cache_rc/$sum_rc > $fre_min){	
	print "$chr\t$pos\t$tag\t$ref\t$_\t$cache_nor\t$cache_rc\t$sum_nor\t$sum_rc\n";
	}
	elsif ($cache_nor/$sum_nor> $fre_min){
	print "$chr\t$pos\t$tag\t$ref\t$_\t$cache_nor\t$cache_rc\t$sum_nor\t$sum_rc\n";
	}
	}
}
}
