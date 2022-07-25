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
my %beta;
my %maf;

#my @file = `ls Single/score/b.score.epacts.top5000 Single/wald/b.wald.epacts.top5000`;
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
			#$AF{$F[3]} = $F[$#F-3]."_".$F[$#F-2]."_".$F[$#F-1]."_".$F[$#F]; # record allele frequency
			$AF{$F[3]} = $F[$#F-3]."\t".$F[$#F-2]."\t".$F[$#F-1]."\t".$F[$#F]; # record allele frequency
			$maf{$F[3]} = int(($F[$#F-3]*$F[$#F-1] + $F[$#F-2]*$F[$#F])/($F[$#F-3]+$F[$#F-2])*1000)/1000;
		}
		if($file =~ m/wald/){
			$beta{$F[3]} = $F[9];
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
	#print $F[0],"_",$F[$#F],"\t";
	print $F[0],"\t";
}
print "Wald_Beta\tTotal_Freq\tCASE_Num\tCTRL_Num\tCASE_Freq\tCTRL_Freq\tNum(p<=1e-3)\tMinP\n";

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

		# print beta 
		if(exists $beta{$id}){
			print $beta{$id},"\t";
		}else{
			print "-\t";
		}
		# print MAF
		if(exists $maf{$id}){
			print $maf{$id},"\t";
		}else{
			print "-\t";
		}
		
		# print allele frequency
		if(exists $AF{$id}){
			print $AF{$id},"\t";
		}else{
			print "-\t";
		}

		print "$pvalue_count\t$min_pvalue\n";
}
