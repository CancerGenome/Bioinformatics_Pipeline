#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:combine.poupulation.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 23 May 2018 10:12:56 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my %pop;
while(my $line = <DATA>){
	chomp $line;
	my @F = split/\s+/,$line;
	$pop{$F[0]} = $F[1];
}

my %hash;
open IN, "/home/yulywang/db/list/20130606_g1k.ped";
while(my $line = <IN>){
	#BB01    HG01879 0       0       1       0       ACB
	chomp $line;
	my @F=split/\s+/,$line;
	#$hash{$F[1]} = $pop{$F[6]}; # JPT to EAS, use big population name
	$hash{$F[1]} = $F[6]; #  keep sub population
}
$hash{"1_AD0469"} = "AD0469";
$hash{"2_AD0530"} = "AD0530";
$hash{"UMAD-14_UMAD-14"} = "AD0014";

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if(exists $hash{$F[1]}){
		print $hash{$F[1]},"\t$F[1]\t$F[2]\t$F[3]\t$F[4]\n";
	}else{
		print "FMD\t$F[1]\t$F[2]\t$F[3]\t$F[4]\n";
	}
}

__DATA__
CHB	EAS
JPT	EAS
CHS	EAS
CDX	EAS
KHV	EAS
CEU	EUR
TSI	EUR
FIN	EUR
GBR	EUR
IBS	EUR
YRI	AFR
LWK	AFR
GWD	AFR
MSL	AFR
ESN	AFR
ASW	AFR
ACB	AFR
MXL	AMR
PUR	AMR
CLM	AMR
PEL	AMR
GIH	SAS
PJL	SAS
BEB	SAS
STU	SAS
ITU	SAS
