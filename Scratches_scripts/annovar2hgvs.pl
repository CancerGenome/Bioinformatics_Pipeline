#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/Users/yulywang/bin/annovar2hgvs.pl  -h
#        DESCRIPTION: -h : Display this help
#        -c: column number, default 1
#        Convert Annovar output to HGVS
#        ----> COL5A3:NM_015719:exon11:c.G1249A:p.D417N to COL5A1,c.1249G>A,pGln417Lys
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed Jan 27 22:19:55 2021
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_c);
getopts("hc:");
if(defined $opt_c){
	$opt_c = $opt_c -1;
}else{
	$opt_c = 0;
}
my %aa; 

while(my $line = <DATA>){ # read in the protein and short code
	chomp $line;
	my @A = split/\s+/,$line;
	$aa{$A[0]} = $A[1];
}

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $string = $F[$opt_c];
	my @G = split/,/,$string; # per annotation
	for my $i (0..$#G){
		my @H = split/:/,$G[$i]; 
		my $gene = $H[0];
		#print "Gene\t$gene\n";
		my $geneid = $H[1];
		my $exon = $H[2];
		my $nucleotide = $H[3];
		my $protein = $H[4];
		my $index = $i + 1;
		if($nucleotide =~ /dup|ins|del/){
			print $index,"\t",$G[$i],"\t",join(" / ",@G),"\n";
		}elsif($G[$i] eq "."){
			print $index,"\t.\t",join(" / ",@G),"\n";
		}else{
			print $index,"\t",$gene," ";
			if($nucleotide =~ /c.([ACGT])(\d+)([ACGT])/){
				print "c.$2$1>$3,";
			}
			if($protein =~ /p.([A-Z])(\d+)([A-Z])/){
				print "(p.$aa{$1}$2$aa{$3})\t";
			}
			print join(" / ",@G),"\n";
		}
	}
}

__DATA__
A	Ala	Alanine
R	Arg	Arginine
N	Asn	Asparagine
D	Asp	Aspartic
C	Cys	Cysteine
E	Glu	Glutamic
Q	Gln	Glutamine
G	Gly	Glycine
H	His	Histidine
O	Hyp	Hydroxyproline
I	Ile	Isoleucine
L	Leu	Leucine
K	Lys	Lysine
M	Met	Methionine
F	Phe	Phenylalanine
P	Pro	Proline
U	Glp	Pyroglutamatic
S	Ser	Serine
T	Thr	Threonine
W	Trp	Tryptophan
Y	Tyr	Tyrosine
V	Val	Valine
X   Ter Stopcodon
