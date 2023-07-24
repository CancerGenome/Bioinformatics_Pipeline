#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/print_fix_line.pl  -h
#        DESCRIPTION: -h : Display this help
#        -n : number of lines to merge as one one
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 10 Dec 2018 02:55:20 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_n);
getopts("hn:");

if(not defined $opt_n){
	$opt_n = 1;
}

my $i = 0;
while(my $line = <>){
	chomp $line;
	print $line,"\t";
	$i++; 
	if($i == $opt_n){
		print "\n";
		$i = 0;
	}
}
