#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:add_pathway_to_groupfile.pl  -h <Pathway File> <Group File for Epacts>
#        DESCRIPTION: -h : Display this help
#        READ in a pathway data, and add the pathways to group.file
#        Format: GSEA format: first column pathway name, second: annotation, third- : all genes
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Sun 16 Jun 2019 11:04:58 PM EDT
#===========================================================================
)
}
#use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my %hash; # exist of each gene, for a quick index
my %gene; # store pathway to gene
my %pathway; # store eah pos to pathway

open IN, "$ARGV[0]";
while(my $line = <IN>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $pathway_name = $F[0];
	for my $i(2..$#F){ # starting from third column, gsea format
		$hash{$F[$i]} = 1; # record gene
		push(@{$gene{$F[$i]}},$pathway_name); # put each pathway in to each gene 
		#print "$F[$i]\t$pathway_name\n";
	}
}
close IN;

open GROUP, "$ARGV[1]";
while(my $line = <GROUP>){
	chomp $line;
	my @F = split/\s+/,$line; # first column is name, then are all pos
	my $gene_name = $F[0];

	print join("\t",@F),"\n";

	if(exists $hash{$gene_name}){
		my @pathway = @{$gene{$gene_name}};
		#print $gene_name,"\t", join("\t",@pathway),"\n";
		foreach my $p (@pathway){
			push(@{$pathway{$p}}, @F[1..$#F]) # push all variants to this pathway
		}
	}
}
close GROUP;


foreach my $key (keys %pathway){
	my @P = @{$pathway{$key}};
	print $key,"\t", join("\t",@P),"\n";
}

