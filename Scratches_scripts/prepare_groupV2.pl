#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:prepare_group.pl  -h -c 
#        DESCRIPTION: -h : Display this help
#        Input format: chr, pos, ref, alt .... gene (column 10)
#        -c: column names for gene, default 10
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 18 Feb 2019 11:59:25 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_c);
getopts("hc:");

my %hash; # sotre all info field
my %exists; # check exist of info
my @gene; # store all gene name ,with order
if(not defined $opt_c){
	$opt_c = 10;
}
$opt_c--;

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	my @G = split/\\/,$F[$opt_c];
	my $gene_name = $G[0];
	my $info = $F[0].":".$F[1]."_".$F[2]."/".$F[3];
	if(not exists $exists{$info}){
		push(@{$hash{$gene_name}}, $info);
		$exists{$info} =  1;
	}

	if(not exists $exists{$gene_name}){
		push(@gene,$gene_name);
		$exists{$gene_name} =  1;
	}
}

for my $i(0..$#gene){
	my $gene = $gene[$i];
	print "$gene\t",join("\t",@{$hash{$gene}}),"\n";
}
