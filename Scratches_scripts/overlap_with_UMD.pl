#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:overlap_with_UMD.pl  -h -c
#
#        Check UMD database, chr,pos,ref,alt, and print their annotation 
#
#        DESCRIPTION: -h : Display this help
#        -c: 1,2,3,4, correspond to chr, pos, ref, alt
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  2018年02月22日 星期四 16时19分34秒
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_c);
getopts("hc:");
$opt_c || &usage();

my %hash;

open IN, "~/db/human/UMD_Prediction/sort/UMD.All ";
#open IN, "gzip -dc ~/db/human/UMD_Prediction/sort/UMD.All.gz| ";
#open IN, "gzip -dc ~/db/human/UMD_Prediction/sort/test.gz| ";

while(my $line = <IN>){
	chomp $line;
	my @F = split/\t/,$line;
	$F[11] =~ s/\s+/_/;
	$hash{$F[0]}{$F[1]}{$F[6]}{$F[7]} .= $F[11];
}

my @C = split/,/,$opt_c;
for my $i(0..$#C){
	$C[$i]--;
}

while(my $line = <>){	
	chomp $line;
	my @F = split/\t/,$line;
	if($F[$C[0]] eq "Chr"){
		print "UMD\t",join("\t",@F),"\n";
		next;
	}

	if(exists $hash{$F[$C[0]]}{$F[$C[1]]}{$F[$C[2]]}{$F[$C[3]]}){
		print "$hash{$F[$C[0]]}{$F[$C[1]]}{$F[$C[2]]}{$F[$C[3]]}\t";
		print join("\t",@F),"\n";
	}else{
		print "-\t",join("\t",@F),"\n";
	}
}
