#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:../bin/gatk_vcf_convert.pl  -h
#        DESCRIPTION: -h : Display this help
#
#        IMPORTANT: Header of VCF normal sample should include blood, otherwise treat first column as normal sample
#
#        Design specificaly for GATK result
#        Output chr pos, rs, status, tumor_ref, tumor_var, tumor_freq, normal_ref, normal_var, normal_freq, SampleID if have multiple
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 07 Sep 2016 03:19:38 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

#1	158225246	.	C	A	.	PASS	SOMATIC;VT=SNP	GT:AD:BQ:DP:FA:SS	0:44,0:.:44:0.00:0	0/1:21,4:42:25:0.160:2
#1	15688	.	C	T	.	REJECT	.	GT:AD:BQ:DP:FA	0:1,0:.:1:0.00	0/1:0,1:42:1:1.00
#1	17614	rs201057270	G	A	.	REJECT	DB	GT:AD:BQ:DP:FA	0:6,0:.:4:0.00	0/1:2,2:37:4:0.500
# Output chr pos, rs, status, tumor_ref, tumor_var, tumor_freq, normal_ref, normal_var, normal_freq
#
my @Header;
while(my $line = <>){
	next if($line =~/^##/);
	chomp $line;
	if($line =~/#CHROM/){
		@Header = split/\s+/,$line;
		next;
	}
	my $normal_column = 9; 

	for my $i (0..$#Header){
		if($Header[$i] =~ /blood/){
			$normal_column = $i;
		}
	}

	my @F = split/\s+/,$line;

	my @N = split/[:,]/,$F[$normal_column];

	for my $i(9..$#F){
		
		next if($i eq $normal_column);

		print "$F[0]\t$F[1]\t$F[2]\t$F[5]\t";

		my @T = split/[:,]/,$F[$i];
		if($#T != 7 ){
			print "NA\tNA\tNA\t";	
		}
		else{
			print "$T[1]\t$T[2]\t";
			print int(100*$T[2]/($T[1]+$T[2]))/100,"\t";
		}
		if($#N != 7){
			print "NA\tNA\tNA\t$Header[$i]\n";	
		}
		else{
			print "$N[1]\t$N[2]\t";
			print int(100*$N[2]/($N[1]+$N[2]))/100,"\t$Header[$i]\n";
		}
	}
}
