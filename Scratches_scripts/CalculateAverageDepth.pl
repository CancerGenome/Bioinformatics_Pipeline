#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:CalculateAverageDepth.pl  -h -d [10] -t 
#        DESCRIPTION: -h : Display this help
#        -d: Also report the total number for depth 10
#        -t: total number of region
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
our ($opt_h,$opt_d,$opt_t);
getopts("hd:t:");
if(defined $opt_d){
	print "File\tTotalReadsTarget\tTargetCoverage\tMeanDepthTarget\tTargetCoverage_depthN\n";
}
else{
	print "File\tTotalReadsTarget\tTargetCoverage\tMeanDepthTarget\n";
}

my @file = `ls data/*.depth`;
chomp @file;
my $sum = 0 ;
my $dep10 = 0;
foreach  my $file (@file){
	open IN, $file;
	while(my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;
		$sum += $F[3];
		if(defined $opt_d){
			if($F[3]/($F[2]-$F[1]+1) >= $opt_d){
				$dep10 = $dep10 + ($F[2]-$F[1]+1);
			}
		}
	
	}
	if(defined $opt_d){
		print $file,"\t$sum\t$opt_t\t",int($sum/$opt_t*100)/100,"\t",$dep10,"\n"; 
	}else{
		print $file,"\t$sum\t$opt_t\t",int($sum/$opt_t*100)/100,"\n"; 
	}
	$sum = 0 ;
	$dep10 = 0;
	close IN;
}
