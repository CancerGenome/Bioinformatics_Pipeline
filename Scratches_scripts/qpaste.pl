#!/usr/bin/perl -w
sub usage (){
    die qq(
#==========================================================================
#        USAGE:CalculateAverageDepth.pl  -h -l -c
#        DESCRIPTION: -h : Display this help
#
#        -l: file list to combine
#        -c: which column to keep, Default: 1,2,3
#        -d: which column to paste, Default: 4
#        -w: width of each file, Default: 4
#        Output: 
#        chr start end NA NA NA.
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
our ($opt_h,$opt_c,$opt_l,$opt_d,$opt_w);
getopts("hc:l:d:w:");
if(not defined $opt_c){
	$opt_c = "1,2,3" ;
}
if(not defined $opt_d){
	$opt_d = 4 ;
}
if(not defined $opt_w){
	$opt_w = 4 ;
}

my @col = split/\,/,$opt_c;
for my $i (0..$#col){
	$col[$i] = $col[$i] - 1;
	print "Header","_",$i+1,"\t"; # header
}
$opt_d = $opt_d -1 ; 
#print "Opt:$opt_d\t$opt_w\n";

my @file;
if(defined $opt_l){
	@file = `cat $opt_l`;
}else{
	@file = `ls *.cnr`; 
}
chomp @file;

# No Header at all
my $cmd = join("\t",@file);
print "$cmd\n"; # header

open IN, "paste $cmd |" ;
	while(my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;
		print join("\t",@F[@col]);
		for my $i(0..$#file){
			#print $opt_d+$i*$opt_w,"\n";
			print "\t",$F[$opt_d + $i * $opt_w];
		}
		print "\n";
	}
close IN;
