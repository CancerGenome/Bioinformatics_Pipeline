#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:prepare_cnn.pl  -h -t [Target File] STDIN [Depth File] > STDOUT
#        DESCRIPTION: -h : Display this help
#        Design specific for CNVKit.py
#        -t: target file with annotation, format: chr, start, end, gene. by cnvkit.py target WES2015.bed --annotate refFlat.nochr.txt -o WES2015.anno.bed
#        -stdin: depth file: format: chr, start, end, total_reads, by samtools bedcov -q1 
#        
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 14 May 2020 03:25:47 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_t, $opt_d);
getopts("ht:d:");

my %gene;

open IN, "$opt_t";
while (my $line = <IN>){
    chomp $line;
    my @F = split/\s+/,$line;
	$gene{$F[0]}{$F[1]}{$F[2]} = $F[3];
}
close IN;

my @header = qw{chromosome      start   end     gene    depth   log2};
print join("\t",@header),"\n";

while (my $line = <>){
    chomp $line;
    my @F = split/\s+/,$line;
	my $length = $F[2]-$F[1]+1;
	my $depth = int($F[3]/$length*100)/100;
	my $log2;
	if($depth == 0){
		$log2 = 1e-10;
	}else{
		$log2 = int(log2($depth)*100)/100;
	}

	print "$F[0]\t$F[1]\t$F[2]\t";
	if(exists $gene{$F[0]}{$F[1]}{$F[2]}){
			print "$gene{$F[0]}{$F[1]}{$F[2]}","\t";
	}else{
		print "-";
	}
	print "$depth\t$log2\n";
}

    sub log2 {
        my $n = shift;
        return log($n)/log(2);
    }
