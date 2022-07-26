#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:fa2excel.pl  -h -a
#        DESCRIPTION: -h : Display this help
#        -a : print the origianl sequence 
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 09 Jan 2019 04:11:45 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_a);
getopts("ha");

while(my $line = <>){
	chomp $line;
	$line =~ s/\>//;
	my $line2 = <>;
	chomp $line2;
	my @F = split//,$line2;
	if(defined $opt_a){
		print $line,"\t",$line2,"\t",join("\t",@F),"\n";
	}else{
		print $line,"\t",join("\t",@F),"\n";
	}
}
