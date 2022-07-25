#!/usr/bin/perl -w
sub usage (){
    die qq(
#==========================================================================
#        USAGE:CalculateAverageDepth.pl  -h -d [10] -l 
#        DESCRIPTION: -h : Display this help
#        -l: file list to combine
#        -d: [10],report the total number of samples with depth >= opt_d,
#        Output: 
#        chr start end #_sample_matching_opt_d criteria, each same mean depth
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 10 Oct 2019 03:06:01 PM DST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_d,$opt_t,$opt_l);
getopts("hd:t:l:");
if(not defined $opt_d){
	$opt_d = 10 ;
}

my @file;
if(defined $opt_l){
	@file = `cat $opt_l`;
}else{
	@file = `ls data/*.depth`; 
}
chomp @file;
my $cmd = join("\t",@file);
print "#Chr\tStart\tEnd\t","Number_ofSampleMeetDepth_Criteria\t$cmd\n";

open IN, "paste $cmd |" ;
	while(my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;
		print "$F[0]\t$F[1]\t$F[2]\t";
		my $length = $F[2] - $F[1]; # bed length
		my $sum = 0 ; # total sample size >= 10
		my @output;
		for my $i(0..$#file){
			my $mean_depth = int(($F[$i*4 + 3]/$length)*10)/10;
			#print $mean_depth,"\t";
			push(@output,$mean_depth);
			if($mean_depth>= $opt_d){
				$sum++;
			}
		}
		print "$sum\t",join("\t",@output),"\n";
	}

#foreach  my $file (@file){
#	open IN, $file;
#	while(my $line = <IN>){
#		chomp $line;
#		my @F = split/\s+/,$line;
#		$sum += $F[3];
#		if(defined $opt_d){
#			if($F[3]/($F[2]-$F[1]+1) >= $opt_d){
#				$dep10 = $dep10 + ($F[2]-$F[1]+1);
#			}
#		}
#	
#	}
#	if(defined $opt_d){
#		print $file,"\t$sum\t$opt_t\t",int($sum/$opt_t*100)/100,"\t",$dep10,"\n"; 
#	}else{
#		print $file,"\t$sum\t$opt_t\t",int($sum/$opt_t*100)/100,"\n"; 
#	}
#	$sum = 0 ;
#	$dep10 = 0;
#	close IN;
#}
