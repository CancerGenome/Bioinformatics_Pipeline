#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/format_MIPS.burden.details.pl  -h
#        DESCRIPTION: -h : Display this help
#        -f : file for MIPS gene list, first column list name, followed by gene names
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 06 Jul 2020 03:08:39 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_f);
getopts("hf:");
if(not defined $opt_f){
	$opt_f="/home/yulywang/db/list/200729_MIPS_gene.list_withPed";
}

my %hash;

#open IN,"/home/yulywang/db/list/200706_MIPS.list";
#open IN,"/home/yulywang/db/list/200729_MIPS_gene.list";
open IN,$opt_f;

while (my $line = <IN>){
    chomp $line;
    my @F = split/\s+/,$line;
	$F[0] = $F[0].",";
	for my $i (1..$#F){
		$hash{$F[$i]} .= $F[0];
	}
}

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if($F[2] ne "-"){
		print $hash{$F[2]},"\t";
	}elsif($F[23] ne "-"){
		$F[2] = $F[23];
		print $hash{$F[23]},"\t";
	}else{
		print "-","\t";
	}

	# force dis_vs_nodis and ane_noane count as -, because they are not accurate
	if($F[0] eq "adult_dis_vs_nodis" || $F[0] eq "adult_ane_vs_noane"){
		$F[21] = "-"; # the number for case control is not right, so set to "-"
		$F[22] = "-";
		$F[60] = "-";
		$F[61] = "-";
		$F[62] = "-";
		$F[63] = "-";
		$F[64] = "-";
		$F[65] = "-";
		$F[66] = "-";
		$F[67] = "-";
	}

	# add min_P for all NonSKAT Pvalue
	my $min_P = $F[20];
	if($min_P eq "-"){
		$min_P = $F[59];
	}
	if($min_P > $F[59]){
		$min_P = $F[59];
	}

	foreach my $i(0..$#F){
		if($F[$i] eq "NA"){
			$F[$i] = "-"
		}
	}
	print join("\t",@F),"\t$min_P\t\n";
}
