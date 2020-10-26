#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:get_eachGene_promoter_enhancer.pl  -h [Gene_TSS Position]
#        DESCRIPTION: -h : Display this help
#        Input format:
#        Gene Chr Strand Start End
#        Output Format:
#        Any poxmial enhancer with in 2000 bp of TSS
#        Any distal enhancer within the gene body
#        Any promoters with in 200 bp of TSS
#
#        Caveat: given a gene, only output the enhancer/promoter in one isoform, Will NOT OUTPUT sum of all ISOFORM
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
	my $chr = $F[1];
	my $pos1 = $F[3];
	my $pos2 = $F[4];
	my $TSS = $pos1; 
	if($F[2] eq "-"){
		$TSS = $pos2;
	}
	#print "$line\t$TSS\n";
	##### proxiam Enhancer 2000 bp
	my ($pELS, $dELS, $FANTOM_Enhancer, $PLS, $FANTOM_Promoter) = qw{0 0 0 0 0};
	`rm cache2`;
	`echo "$chr\t$TSS"| awk '{print \$1"\t"\$2-2000"\t"\$2+2000}' | sed 's/^chr//'> cache2`;
	$pELS = `less cache2 | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_pELS.avinput.hg19_multianno.txt|  awk '{print \$NF}' | datamash sum 1`;
	##### Promoter 200bp
	`echo "$chr\t$TSS"| awk '{print \$1"\t"\$2-200"\t"\$2+200}' | sed 's/^chr//'> cache2`;
	$PLS = `less cache2 | bedtools merge -i stdin | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_PLS.avinput.hg19_multianno.txt|  awk '{print \$NF}' | datamash sum 1`;

	#### distal Enhancer within Gene 
	`echo "$chr\t$pos1\t$pos2"| awk '{print \$1"\t"\$2"\t"\$3}' | sed 's/^chr//'> cache2`;
	$dELS = `less cache2 | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_dELS.avinput.hg19_multianno.txt|  awk '{print \$NF}' | datamash sum 1`;
	chomp $pELS;
	chomp $dELS;
	chomp $PLS;

	$pELS = "0" if($pELS eq "");
	$dELS = "0" if($dELS eq "");
	$PLS = "0" if($PLS eq "");
	
	#print "$gene\t$pELS\t$dELS\t$PLS\t$FANTOM_Enhancer\t$FANTOM_Promoter\n";
	print "$gene\t$pELS\t$dELS\t$PLS\n";
}
