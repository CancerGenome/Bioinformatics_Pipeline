#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:get_enhancer2Kb.pl  -h [Gene List] [Column for distance] [File with distance]
#        DESCRIPTION: -h : Display this help
#        Gene list: list of gene to check
#        Column for distance: which column contain information dist=***, usually annotation from annovar
#        By default, will only keep those element within 2Kb, 2Kb is the definition of ENCODE CCREs pELS (enhancer like element)
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 04 Sep 2020 02:27:03 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

#1	150265835	150266011	0	0	upstream	MRPS21	dist=251	.	.	upstream	ENSG00000187145	dist=278	.	.

my %gene;
my $threshold = 2000; # control the distance threshold
open GENE, $ARGV[0];
while (my $line = <GENE>){
    chomp $line;
    my @F = split/\s+/,$line;
	$gene{$F[0]} = 1;
}
close GENE;

my $col = $ARGV[1];
$col--;

open IN, $ARGV[2];
while (my $line = <IN>){
    chomp $line;
    my @F = split/\s+/,$line;
	my $print = 0 ; # control print or not
	$gene{$F[0]} = 1;
	my @G = split/;/,$F[$col-1]; # gene name
	my @D = split/;/,$F[$col]; # dist

	if($F[5] eq "intergenic"){
		for my $i(0..$#G){
			my $gene_name = $G[$i];
			next if not exists $gene{$gene_name};
			my $distance = $D[$i];
			$distance =~ s/dist=//;
			if($distance <= $threshold){
				$print = 1;
			}
		}
	}else{
		for my $i(0..$#G){
			my $gene_name = $G[$i];
			if (exists $gene{$gene_name}){
				$print = 1;
			}
		}
	} # end else

	if($print == 1 ){
		print join("\t",@F),"\n";
	}
}



