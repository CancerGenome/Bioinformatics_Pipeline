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
#print "#Chr\tPos\tRef\tNor\tRc\tNor_maj\tRc_maj\tSum_nor\tSum_rc\n";
my %nor=("A" =>15,"C"=>16,"G"=>17,"T"=>18,"-"=>0
		);
my %rc=("A" =>23,"C"=>24,"G"=>25,"T"=>26,"-"=>0
		);
open NOMATCH,">no_coincide_mutate";
while(<>){
	next if (/#/);
	chomp;
	split;
	my ($chr,$ref,$pos,$tag
			,$sum_nor ,$sum_rc
			,$nor_dep ,$rc_dep
			,$maj_nor , $maj_rc
			,$sec_nor ,$sec_rc
			,$maj_nor_base ,$maj_rc_base
			,$sec_rc_base ,$sec_nor_base
			,$mut_rc ,$mut_nor
			);
	$chr = $_[0];
	$ref = $_[2];
	$pos = $_[1];
	$maj_nor_base = $_[13];
	$maj_rc_base = $_[21];
	$sec_nor_base = $_[14];
	$sec_rc_base = $_[22];


			for my $i (15..18){
				$sum_nor += $_[$i];	
			}
			for my $i (23..26){
				$sum_rc += $_[$i];	
			}
	next if($sum_rc ==0);
	next if($sum_nor ==0);

	$nor_dep = int($_[12]*$sum_nor+0.5);  # ture depth
	$rc_dep = int($_[20]*$sum_rc+0.5);

	$maj_nor = int($_[12]*$_[$nor{$maj_nor_base}]+0.5); # maj depth
	$maj_rc = int($_[20]*$_[$rc{$maj_rc_base}]+0.5);

#------- change second allele
	
	my $null =$sec_rc_base eq "-" ?  ($sec_rc = 0):( $sec_rc = int($_[12]*$_[$rc{$sec_rc_base}]+0.5));
	$null = $sec_nor_base eq "-" ?  ($sec_nor = 0):( $sec_nor = int($_[20]*$_[$nor{$sec_nor_base}]+0.5));

	next if ($sec_rc+$sec_nor<=2);
#------- above is raw data process

#------- filter for mutant

	($maj_rc_base eq $ref) ? ($mut_rc =$sec_rc_base) : ($mut_rc=$maj_rc_base);
	($maj_nor_base eq $ref) ? ($mut_nor =$sec_nor_base) : ($mut_nor=$maj_nor_base);

    if ($mut_rc ne $mut_nor and $mut_rc ne "-"  and $mut_nor ne "-"){
		print NOMATCH $_,"\t$maj_nor_base\t$sec_nor_base\t$maj_rc_base\t$sec_rc_base\t$maj_nor\t$sec_nor\t$maj_rc\t$sec_rc\n";
	}
	else {

	print $_,"\t$maj_nor_base\t$sec_nor_base\t$maj_rc_base\t$sec_rc_base\t$maj_nor\t$sec_nor\t$maj_rc\t$sec_rc\n";
	}



=head
	if ($ref ne $maj_nor_base && $maj_nor_fre >= $min_fre){	
		if ($ref ne $maj_rc_base && $maj_rc_fre >= $min_fre){	
			print "$chr\t$pos\t$ref\t$maj_nor_base\t$maj_rc_base\tB\t$maj_nor\t$maj_rc\t$nor_dep\t$rc_dep\n"; # both
		}
		else {
			print "$chr\t$pos\t$ref\t$maj_nor_base\t$maj_rc_base\tN\t$maj_nor\t$maj_rc\t$nor_dep\t$rc_dep\n"; # normal
		}
}
	elsif ($ref ne $maj_rc_base && $maj_rc_fre >= $min_fre){	
			print "$chr\t$pos\t$ref\t$maj_nor_base\t$maj_rc_base\tR\t$maj_nor\t$maj_rc\t$nor_dep\t$rc_dep\n"; #recur
}
my $maj_nor_fre = $_[$nor{$maj_nor_base}]/$sum_nor;
	my $maj_rc_fre = $_[$rc{$maj_rc_base}]/$sum_rc;
print "$ref\t$maj_nor_base\t$nor_dep\t$maj_nor\t$maj_nor_fre\n";	
=cut
}
