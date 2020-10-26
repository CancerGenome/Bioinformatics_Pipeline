#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE: Get_LD_Sgement.pl -h -r [File/Multiple Files]
#
#        DESCRIPTION: -h : Display this help
#
#        Input file should from ldlink ld proxy api download, script: Get_LD_1000G_EUR.pl
#
#        -m: MAF threshold, remove variants below this, default: 0.1
#        -r: threshold for r^2, default: 0.2
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 03 Sep 2020 03:45:38 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_m,$opt_r);
getopts("m:r:h");
if(not defined $opt_m){
	$opt_m = 0.1;
}
if(not defined $opt_r){
	$opt_r = 0.2;
}

#rs12041871      chr1:247377541  (A/T)   0.3579  0       1.0     1.0     A=A,T=T 6       NA
my @file = @ARGV;

foreach my $file (@file){
	chomp $file;
	open IN, $file;
	<IN>;
	my $chr = "chr1";
	my $min = 100000000000 ;
	my $max = 0 ;
	while (my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;
		next if($F[3] < $opt_m); # MAF > 0.1
		next if($F[6] < $opt_r); # r^2 0.8
		my @G = split/:/,$F[1];
		$chr = $G[0];
		$chr =~ s/chr//;
		if($min > $G[1]){
			$min = $G[1];
		}
		if($max < $G[1]){
			$max = $G[1];
		}
	}
	if($min == $max){
		$min = $min -1;
	}
	print "$chr\t$min\t$max\t$file\n";
	close IN;
}
