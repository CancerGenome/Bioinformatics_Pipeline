#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:get_eachGene_promoter_enhancer.pl  -h [Gene_TSS Position]
#        DESCRIPTION: -h : Display this help
#        Input format:
#        Gene 
#        Output Format:
#        Any poxmial enhancer with in 2000 bp of TSS
#        Any distal enhancer within the gene body
#        Any promoters with in 200 bp of TSS
#
#        Caveat: given a gene, output the enhancer/promoter among all isoforms
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 16 Sep 2020 03:31:28 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

print "Gene\tpELS\tdELS\tPLS\n";

open IN, $ARGV[0];
while (my $line = <IN>){
    chomp $line;
    my @F = split/\s+/,$line;
	my $gene = $F[0];
	##### proxiam Enhancer 2000 bp
	my ($pELS, $dELS, $FANTOM_Enhancer, $PLS, $FANTOM_Promoter) = qw{0 0 0 0 0};
	$pELS = `echo $gene | fetch.pl -q1 -d3 - ~/db/anno/hg19_refseq.2020.TSS | awk '{print \$1"\t"\$2-2000"\t"\$2+2000"\t"\$3}' | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_pELS.avinput | cut -f5-7 | sumbed.sh - `;
	##### Promoter 200bp
	$PLS = `echo $gene | fetch.pl -q1 -d3 - ~/db/anno/hg19_refseq.2020.TSS | awk '{print \$1"\t"\$2-200"\t"\$2+200"\t"\$3}' | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_PLS.avinput | cut -f5-7 | sumbed.sh - `;
	#### distal Enhancer within Gene 
	$dELS = `echo $gene | fetch.pl -q1 -d13 - ~/db/anno/hg19_refseq.2020 | cut -f3,5,6,13 | uniq | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_dELS.avinput | cut -f5-7 | sumbed.sh - `;
	chomp $pELS;
	chomp $dELS;
	chomp $PLS;

	$pELS = "0" if($pELS eq "");
	$dELS = "0" if($dELS eq "");
	$PLS = "0" if($PLS eq "");
	
	#print "$gene\t$pELS\t$dELS\t$PLS\t$FANTOM_Enhancer\t$FANTOM_Promoter\n";
	print "$gene\t$pELS\t$dELS\t$PLS\n";
}
