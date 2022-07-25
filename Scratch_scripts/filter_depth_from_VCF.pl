#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/filter_depth_from_VCF.pl  -h -p -d
#        DESCRIPTION: -h : Display this help
#        -p: proportion of samples matching DP criteria [default: 90% or 0.90]
#        -d: DP criteria [default: 10]
#
#        Author: Wang Yu
#        Input format: bcftools query -f '%CHROM\t%POS\t[%DP\t]\n' test/WES.overlap.vcf.gz
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 03 Feb 2020 10:07:48 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_d,$opt_p);
getopts("hd:p:");

if(not defined $opt_d){
	$opt_d = 10;
}
if(not defined $opt_p){
	$opt_p = 0.9;
}

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/, $line;
	my $n = 0 ;
	my $total =  $#F -2 + 1;
	for my $i(2..$#F){
		next if($F[$i] eq ".");
		$n ++ if ($F[$i]>$opt_d);
	}

	if($n/$total > $opt_p){
		#print $F[0],"\t",$F[1],"\t$n\t$total\n";
		print $F[0],"\t",$F[1],"\n";
	}
}

