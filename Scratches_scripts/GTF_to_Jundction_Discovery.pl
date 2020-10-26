#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:format_to_junction_discovery.pl  -h
#        DESCRIPTION: -h : Display this help
#        Given GTF file, covert to BC pipeline, SpliceJunctionDiscovery.sh first input
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 28 Oct 2019 10:17:18 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

while(my $line = <>){
	chomp $line;
	my @F = split/\t+/,$line;
	my $gene_name;
	my $gene_id; 
	my $gene_type; 

	if($F[8] =~/gene_name "(.+?)";/){
		$gene_name = $1;
	}
	if($F[8] =~/gene_id "(.+?)";/){
		$gene_id = $1;
	}
	if($F[8] =~/gene_type "(.+?)";/){
		$gene_type = $1;
	}
	print "$gene_name\t$gene_id\t-\t$F[0]\t$F[3]\t$F[4]\t$gene_type\n";

}
