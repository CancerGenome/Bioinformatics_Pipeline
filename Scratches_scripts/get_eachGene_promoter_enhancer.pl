#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:get_eachGene_promoter_enhancer.pl  -h [Gene_TSS Position]
#        DESCRIPTION: -h : Display this help
#        Any promoters with in 200 bp of TSS
#        Any enhancer with in 2000 bp of TSS
#        Auto read MIPS_gene.TSS
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

open IN, "MIPS_gene.TSS";
while (my $line = <IN>){
    chomp $line;
    my @F = split/\s+/,$line;
	my $gene = $F[0];
	my $chr = $F[1];
	my $pos = $F[2];
	##### Promoter 2000 bp
	my ($pELS, $dELS, $FANTOM_Enhancer, $PLS, $FANTOM_Promoter) = qw{0 0 0 0 0};
	`grep -w $gene MIPS_gene.TSS| awk '{print \$2"\t"\$3-2000"\t"\$3+2000}' | sed 's/^chr//'> cache`;
	$pELS = `less cache | bedtools merge -i stdin | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_pELS.avinput.hg19_multianno.txt|  awk '{print \$NF}' | datamash sum 1`;
	$dELS = `less cache | bedtools merge -i stdin | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_dELS.avinput.hg19_multianno.txt|  awk '{print \$NF}' | datamash sum 1`;
	$FANTOM_Enhancer = `less cache | bedtools merge -i stdin | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/FANTOM/FANTOM.enhancer.anno|  awk '{print \$NF}' | datamash sum 1`;
	#### Enhancer 200bp
	`grep -w $gene MIPS_gene.TSS| awk '{print \$2"\t"\$3-200"\t"\$3+200}' | sed 's/^chr//'> cache`;
	$PLS = `less cache | bedtools merge -i stdin | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/ENCODE/Hg19_ccREs_PLS.avinput.hg19_multianno.txt|  awk '{print \$NF}' | datamash sum 1`;
	$FANTOM_Promoter = `less cache | bedtools merge -i stdin | sed 's/^chr//' | bedtools intersect -wo -a stdin -b ~/db/FANTOM/FANTOM.promoter.anno|  awk '{print \$NF}' | datamash sum 1`;

	chomp $pELS;
	chomp $dELS;
	chomp $PLS;
	chomp $FANTOM_Enhancer;
	chomp $FANTOM_Promoter;

	$pELS = "0" if($pELS eq "");
	$dELS = "0" if($dELS eq "");
	$PLS = "0" if($PLS eq "");
	$FANTOM_Enhancer = "0" if($FANTOM_Enhancer eq "");
	$FANTOM_Promoter = "0" if($FANTOM_Promoter eq "");

	print "$gene\t$pELS\t$dELS\t$PLS\t$FANTOM_Enhancer\t$FANTOM_Promoter\n";
}
