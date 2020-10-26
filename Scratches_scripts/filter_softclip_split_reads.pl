#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/filter_softclip_split_reads.pl  -h -s -p
#        DESCRIPTION: -h : Display this help
#
#        Design for ASE_Alternative_Splicing_Event.sh. 
#        -s: softclip with any longer length are removed, default: > 5 bp;
#        -p: split reads length (both end) smaller than this will be removed, default  20bp;
#        
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 17 Dec 2019 10:50:17 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_s, $opt_p);
getopts("hs:p:");
if(not defined $opt_s){
	$opt_s = 5; 
}
if(not defined $opt_p){
	$opt_p = 20; 
}

my $pass = 1 ; # pass =1 means pass all filter
while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	while($F[5] =~ /(\d+)S/g){
		if ($1>5){
			$pass = 0;
		}
	}
	while($F[5] =~ /(\d+)M/g){
		if ($1<20){
			$pass = 0;
		}
	}
	if($pass == 1){ # only print those match criteria
		print $line,"\n";
	}
	$pass = 1; 
}

