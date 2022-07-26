#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/merge_annovar.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 19 Jul 2016 06:03:39 PM EDT
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
open EXONIC,"$ARGV[0].exonic_variant_function";
open ALL,"$ARGV[0].variant_function";

# record all exonic data here
while(my $line1= <EXONIC>){
	chomp $line1;
	my @F = split/\t/,$line1;
	$F[1] =~ s/\s+/_/g; 
	$hash{join("\t",@F[3..$#F])} = $F[1]."\t".$F[2];
	#print "A\t",join("\t",@F[3..$#F]),"\n";
}

while(my $line2 = <ALL>){
	chomp $line2;
	my @F = split/\t/,$line2;
	print join("\t",@F[2..$#F]);

	if($F[0] eq "UTR5" or $F[0] eq "UTR3" or $F[0] eq "splicing"){
#		print "\nM1\n";
		if($F[1] =~/(.+?)\((.+)\)/){
#			print "\nM2\n";
			print "\t$F[0]\t$1\t$2\n";
		}
		else {
			print "\t$F[0]\t$F[1]\t-\n";
		}
	}
	elsif($F[0] eq "exonic" and exists $hash{join("\t",@F[2..$#F])}){
			my @E = split/\t/,$hash{join("\t",@F[2..$#F])} ;
			print "\t$E[0]\t$F[1]\t",$E[1],"\n";
	}
	else{
			print "\t$F[0]\t$F[1]\t-\n";
	}
	#print "B\t",join("\t",@F[2..$#F]),"\n";
}
close ALL;
close EXONIC;

__DATA__
exonic_variant_function: line1   nonsynonymous SNV       AGRN:NM_198576:exon7:c.C1237A:p.R413S,  1       977395  977395  C       A
variant_function: exonic  AGRN    1       977395  977395  C       A       152620T1
variant_function: intergenic      LINC01443(dist=31804),LOC644669(dist=307996)



