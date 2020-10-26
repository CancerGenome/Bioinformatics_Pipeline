#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:combine_epacts.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Design for single variant test, based on V2
#        Created Time:  2018年03月08日 星期四 15时19分37秒
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my %hash; # record pvalue
my %AF; # record  allele frequency and number
my %count; # record gene counts
my $tag = 0; # determin whether to record
my %chr;
my %start;
my %end;

my @file = `ls score/b.score.epacts.top5000 wald/b.wald.epacts.top5000`;

foreach my $file(@file){
	chomp $file;
	open IN, "$file";
	while(my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;  #chro, begin, end, markerID,9th_pvalue (glrt 8th pvalue)
		if($line =~/^#/){ # header file
			if($F[7] eq "PVALUE"){
				$tag = 1; # glrt
			}else{
				$tag = 0; # all others
			}
			next;
		}

		if($tag == 1){
			$hash{$F[3]}{$file} = $F[7];
		}elsif($tag ==0){
			$hash{$F[3]}{$file} = $F[8];
			$AF{$F[3]} = $F[$#F-3]."_".$F[$#F-2]."_".$F[$#F-1]."_".$F[$#F]; # record allele frequency
		}
		$chr{$F[3]} = $F[0];
		$start{$F[3]} = $F[1];
		$end{$F[3]} = $F[2];
	}
}

# print header
print "ID\tChr\tBegin\tEnd\t";
foreach my $file(@file){
	my @F = split/\//,$file;
	print $F[0],"_",$F[$#F],"\t";
}
print "Variant_Count\tNum(p<=1e-3)\tMinP\n";

# print each p-value
foreach my $key (keys %hash){
		my $id = $key;
		print "$id\t$chr{$id}\t$start{$id}\t$end{$id}\t";

		my $pvalue_count = 0 ;
		my $min_pvalue = 1;
		foreach my $file(@file){
			if(exists $hash{$key}{$file}){ # check whether exists
				print $hash{$key}{$file},"\t";
				if($hash{$key}{$file} ne "NA" and $hash{$key}{$file} <= 0.001){
					$pvalue_count++;
				}
				if($hash{$key}{$file} ne "NA" and $hash{$key}{$file} <= $min_pvalue){
					$min_pvalue = $hash{$key}{$file};
				}
			}
			else{
				print "-\t"; 
			}
		}

		if(exists $AF{$id}){
			print $AF{$id},"\t";
		}else{
			print "-\t";
		}
		print "$pvalue_count\t$min_pvalue\n";
}
