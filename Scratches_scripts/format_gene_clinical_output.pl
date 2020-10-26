#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:format_gene_clinical_output.pl  -h
#        DESCRIPTION: -h : Display this help
#        Design for formating the gene clinical output. 
#        Should be directly output to the perl
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 07 Nov 2019 02:08:35 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my %hash;

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	$F[0] =~ s/\d+//g;
	if($F[$#F] eq "NA"){
		$F[$#F] = "-";
	}elsif($F[$#F] =~ /e/){

	}elsif($F[$#F] <= 0.01){
		$F[$#F] = int(1000*$F[$#F]+0.5)/1000;
	}elsif($F[$#F] > 0.01){
		$F[$#F] = int(100*$F[$#F]+0.5)/100;
	}else{

	}
	@{$hash{$F[1]}{$F[0]}}  = @F;
}

# read in keys 
my @key;
while(my $key = <DATA>){
	chomp $key;
	push(@key, $key);
}

foreach my  $gene(sort keys %hash){
	print "-\tGene\t$gene\n";
	for my $i(0..$#key){
		my @output = @{$hash{$gene}{$key[$i]}};
		if($key[$i] eq "no.dissection.aneurysm.bin"){
			next;
		}
		if($key[$i] eq "no.dissection.bin"){
			print "-\t-\t$gene\n";
		}
		if($key[$i] eq "no.aneurysm.bin"){
			print "-\t-\t$gene\n";
		}
		print join("\t",@output),"\n";
	}
}

######
__DATA__
no.fmd
fmd.aorta
fmd.cerebral
fmd.cervical
fmd.ica
fmd.va
fmd.coronary
fmd.le
fmd.ue
fmd.visceral
fmd.mesenteric
fmd.renal
fmd.visceral.other
no.dissection.bin
no.dissection
dissection.aorta
dissection.cerebral
dissection.cervical
dissection.ica
dissection.va
dissection.coronary
dissection.le
dissection.ue
dissection.visceral
dissection.mesenteric
dissection.renal
dissection.visceral.other
no.aneurysm.bin
no.aneurysm
aneurysm.aorta
aneurysm.cerebral
aneurysm.cervical
aneurysm.ica
aneurysm.va
aneurysm.coronary
aneurysm.le
aneurysm.ue
aneurysm.visceral
aneurysm.mesenteric
aneurysm.renal
aneurysm.visceral.other
no.dissection.aneurysm.bin
