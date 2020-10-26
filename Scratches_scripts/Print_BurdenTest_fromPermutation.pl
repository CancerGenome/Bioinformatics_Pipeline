#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Print_BurdenTest_fromPermutation.pl  -h -p (Permutation file)  -d (Deleterious file)
#        DESCRIPTION: -h : Display this help
#        -p: list of permutation file, example ls data/per*/Deleterious/Collapse/Collapse*.epacts
#        -d: deleterious result
#        -r: print header, default off.
#
#        Given permutation result, calculate the top genes FDR rate. 
#        Each gene will give their output of FDR, if FDR is smaller than 0.1
#        For details of permutation, https://docs.google.com/document/d/1nD_5gnvmXgyzeiy9je1q1R3AF5VnUQBXG6yRgTNuI0U/edit
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 13 Jul 2020 07:28:54 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_p, $opt_d, $opt_r);
getopts("hp:d:r");

my @input = `ls $opt_p`;
my $n =  $#input + 1;  # total number of permutation test;

my %perm;  # record permutation pvalue
my %del; # record deleterious pvalue

my $marker_col = 4; 
my $pval_col = 10;
my $fdr_threshold = 0.1; # only print values smaller than 0.1

# read all perm pvalue;
foreach my $input(@input){
	chomp $input;
	open IN, "$input";
	<IN>; # omit header line
	while (my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;
		my $marker = $F[$marker_col - 1];
		my $pval = $F[$pval_col -1];
		next if ($pval eq "NA");
		next if($F[0] eq "multichrs"); # no geneset enrichment

		my @M = split/\_/, $marker; 
		my $gene = join("_",@M[1..$#M]);

		if(not exists $perm{$gene}){
			$perm{$gene} = $pval;
		}elsif($perm{$gene} > $pval){
			$perm{$gene} = $pval; 
		}
	}
	close IN;
}

open IN2, "$opt_d";
<IN2>;
print "Threshold\tGene\t#_Permutation\t#_Real\tFDR\tReal_File\tPermutation_File\n" if(defined $opt_r);
while(my $line = <IN2>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $marker = $F[$marker_col - 1];
	my $pval = $F[$pval_col -1];
	next if ($pval eq "NA");
	next if($F[0] eq "multichrs"); # no geneset enrichment

	my @M = split/\_/, $marker; 
	my $gene = join("_",@M[1..$#M]);
	$del{$gene} = $pval;
}

my $i = 1;  # count of deleterious
foreach my $key (sort {$del{$a} <=> $del{$b}} keys %del){  # sort hash value not key
	my $threshold = $del{$key};
	my $j = 0 ; # count of permutation
	foreach my $keys (keys %perm){
		if($perm{$keys} <= $threshold){
			$j++;
		}
	}
	if($j/$i/$n<= $fdr_threshold){
		print "$threshold\t$key\t$j\t$i\t",$j/$i/$n,"\t",$opt_d,"\t",$opt_p,"\n";
	}
	if($j/$i/$n > $fdr_threshold){
		last;
	}

	#if($j/$i/$n> 0.1){
	#print "Higher\t$threshold\t$key\t$j\t$i\t",$j/$i/$n,"\n";
	#}
	
	$i++; # next gene.
}
