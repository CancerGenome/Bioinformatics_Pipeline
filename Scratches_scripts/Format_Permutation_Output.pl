#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/Format_Permutation_Output.pl  -h
#        DESCRIPTION: -h : Display this help
#        Use to format the result of Print_BurdenTest_fromPermutation.pl
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 13 Jul 2020 11:02:16 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $line = <>;
#print $line;
print "Category\tTest\tThreshold\tGene\n";

my @A = qw{Deleterious LOF_0.01 LOF_0.05 LOF_Nonsyn_0.01 LOF_Nonsyn_0.05};
my @B = qw{collapse madsen VT wcnt};

my %hash;
my %threshold;
while (my $line = <>){
    chomp $line;
    my @F = split/\s+/,$line;
	my @G = split/\//,$F[$#F];
	my $a = $G[$#G-2];
	my $b = $G[$#G-1];
	
	if(not exists $hash{$a}{$b}){
		@{$hash{$a}{$b}} = $F[1];
		$threshold{$a}{$b} = $F[0];
		#	print "$a\t$b\t$F[0]\t$F[1]\n";
	}else{
		push(@{$hash{$a}{$b}},$F[1]);
		$threshold{$a}{$b} = $F[0] if ($F[0] > $threshold{$a}{$b}); # user high pvalue as threshold if mutliple genes
	}
}

foreach my $a(@A){
	foreach my $b(@B){
		if(not exists $hash{$a}{$b}){
			print "$a\t$b\t-\t-\n";
		}else{
			print "$a\t$b\t$threshold{$a}{$b}","\t";
			my @F = @{$hash{$a}{$b}};
			print join(",",@F),"\n";
		}
	}
}
