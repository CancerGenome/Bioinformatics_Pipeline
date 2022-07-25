#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/check_ref_allele.pl  -h
#        DESCRIPTION: -h : Display this help
#        -c: chr number
#        -p: base number
#        -r: Column number for ref and alt allele, example -r3,4
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Given the column of ref allele and alt allele, will read hg19 genome and check whether input ref is same with genome allele. Will have following action:
#        If genome allele = input ref allele --> Input_Ref, Alt_Allele
#        If genome allele = input alt allele --> Alt_Allele, Input_Allele
#        If genome allele = flip input ref allele --> Flip Input_Ref, Flip Alt Allele
#        If genome allele = flip input alt allele --> Flip Alt Allele,Flip Input_Ref
#        Created Time:  Mon 08 Oct 2018 11:02:16 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_r,$opt_c,$opt_p);
getopts("hc:r:p:");

my @R = split/,/,$opt_r;
$R[0]--;
$R[1]--;
$opt_c--;
$opt_p--;

my %reverse = ('A' => 'T', 'T' => 'A', 'G'=> 'C', 'C'=> 'G');

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $input_ref = uc $F[$R[0]];
	my $input_alt = uc $F[$R[1]];
	my $input_chr = uc $F[$opt_c];
	my $pos = $F[$opt_p];
	my $real_ref = `samtools faidx ~/db/human/hs37d5.fa $input_chr:$pos-$pos | tail -n 1`;
	chomp $real_ref;
	#my $real_ref = $ref{$input_chr}[$pos]; # de reference a hash array

	print join("\t",@F),"\t";
	if($real_ref eq $input_ref){
		print "PASS\t$input_ref\t$input_alt\n";
	}elsif($real_ref eq $input_alt){
		print "FLIP\t$input_alt\t$input_ref\n";
	}elsif($real_ref eq $reverse{$input_ref}){
		print "CMPR\t$reverse{$input_ref}\t$reverse{$input_alt}\n";
	}elsif($real_ref eq $reverse{$input_alt}){
		print "CMPA\t$reverse{$input_alt}\t$reverse{$input_ref}\n";
	}elsif($real_ref eq ""){
		print "NA\t-\t-\n";
	}else{
		print "NA\t$real_ref\t-\n";
	}
}
