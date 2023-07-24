#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:combine_epacts.pl  -h
#        DESCRIPTION: -h : Display this help
#        Design for V15 only, because it only have five input.
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
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
my %count; # record gene counts
my $tag = 0; # determin whether to record
my %chr;
my %start;
my %end;

#my @file = `ls */*/*.epacts`; # only different here, V3 versus V2
my @file = `ls */*.epacts`; # only different here, V3 versus V2

foreach my $file(@file){
	chomp $file;
	open IN, "$file";
	while(my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line; # chro, begin, end, markerID,8th_marker,10th_pvalue
		if($line =~/^#/){
			if($F[7] eq "NUM_PASS_VARS"){
				$tag = 1; # non VT
			}else{
				$tag = 0; # VT
			}
			next;
		}

		my @G = split/\_/,$F[3];
		my $id = join("_",@G[1..$#G]);  # id is only gene, designed for the pathway name, always wih _
		$hash{$id}{$file} = $F[9];
		if($tag == 1){
			$count{$id} = $F[7]; # passed variant count
		}else{
			$count{$id} = $F[5] ; # VT data
		}

		# update chr_pos
		$chr{$id} = $F[0];
		if(exists $start{$id}){
			if($F[1] < $start{$id}){
				$start{$id} = $F[1];
			}
		}else{
			$start{$id} = $F[1];
		}
		if(exists $end{$id}){
			if($F[2] > $end{$id}){
				$end{$id} = $F[2];
			}
		}else{
			$end{$id} = $F[2];
		}


	}
}

# print header
print "Gene\tChr\tBegin\tEnd\t";
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

		print $count{$key},"\t";
		print "$pvalue_count\t$min_pvalue\n";
}
