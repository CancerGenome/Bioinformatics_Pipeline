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
# input ruanjue pairup file
use strict;
use warnings;
print "#Chr\tPos\tRef\tNor\tRc\tNor_major\tRc_major\tSum_nor\tSum_rc\n";
my %nor=("A" =>15,"C"=>16,"G"=>17,"T"=>18
		);
my %rc=("A" =>23,"C"=>24,"G"=>25,"T"=>26
		);
my $min_dep =8;
my $min_fre = 0.35;
my @file = `more ~/filelist`;
foreach my $file (@file){
	chomp $file;
open IN,"$file"|| die "Can not open \n";
while(<IN>){
	next if (/#/);
	chomp;
	split;
	my ($chr,$ref,$pos,$tag);
	$chr = $_[0];
	$ref = $_[2];
	$pos = $_[1];
	my $nor_dep = $_[12];
	my $rc_dep = $_[20];
	my $major_nor_base = $_[13];
	my $major_rc_base = $_[21];

	my ($sum_nor,$sum_rc); 
	for my $i (15..18){
	 	$sum_nor += $_[$i];	
	}
	for my $i (23..26){
	 	$sum_rc += $_[$i];	
	}
	next if($sum_rc ==0);
	next if($sum_nor ==0);

	my $total_nor = int($nor_dep*$sum_nor+0.5);
	my $total_rc = int($rc_dep*$sum_rc+0.5);
	my $major_nor = int($nor_dep*$_[$nor{$major_nor_base}]+0.5); # ref no
	my $major_rc = int($rc_dep*$_[$rc{$major_rc_base}]+0.5);
	my $major_nor_fre = $_[$nor{$major_nor_base}]/$sum_nor;
	my $major_rc_fre = $_[$rc{$major_rc_base}]/$sum_rc;
#print "$ref\t$major_nor_base\t$total_nor\t$major_nor\t$major_nor_fre\n";	
# minus depth
	next if ($total_nor <=$min_dep);
	next if ($total_rc <=$min_dep);

	if ($ref ne $major_nor_base && $major_nor_fre >= $min_fre){	
		if ($ref ne $major_rc_base && $major_rc_fre >= $min_fre){	
			print "$chr\t$pos\t$ref\t$major_nor_base\t$major_rc_base\tB\t$major_nor\t$major_rc\t$total_nor\t$total_rc\n"; # both
		}
		else {
			print "$chr\t$pos\t$ref\t$major_nor_base\t$major_rc_base\tN\t$major_nor\t$major_rc\t$total_nor\t$total_rc\n"; # normal
		}
}
	elsif ($ref ne $major_rc_base && $major_rc_fre >= $min_fre){	
			print "$chr\t$pos\t$ref\t$major_nor_base\t$major_rc_base\tR\t$major_nor\t$major_rc\t$total_nor\t$total_rc\n"; #recur
}
}
}
