#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/bcftools_merge_depth.pl  -h
#        DESCRIPTION: -h : Display this help
#        -l : list of files generated from bcftools bedcov (chr, start, end, and number)
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 06 Jan 2020 10:27:35 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_l);
getopts("hl:");

my @List;
my @Header= qw{Chr Start End};

 # read in file list and header
open LIST, $opt_l;
while (my $line = <LIST>){
	chomp $line;
	push(@List, $line);
	my @F = split/\//,$line;
	my $header = $F[0];
	$header =~ s/.sort.bam.depth//;
	push(@Header, $header);
}
close LIST;

foreach $list (@List){
	open IN, $list;
	while(my $line = <IN>){
	
	}
}
