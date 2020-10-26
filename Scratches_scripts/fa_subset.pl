#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  -h -s -e -f
#        DESCRIPTION: -h : Display this help
#        -s: start position
#        -e: end position
#        -f: print for two fasta format, [default: print one line]
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 22 Feb 2019 09:05:51 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_s,$opt_e,$opt_f);
getopts("hs:e:f");
$opt_s--;
$opt_e--;

while(my $line = <>){
	chomp $line;
	my $line2 = <>;
	chomp $line2;
	my @F = split//,$line2;
	$line2 = join("",@F[$opt_s..$opt_e]);
	if(defined $opt_f){
		print "$line\n$line2\n";
	}else{
		print "$line\t$line2\n";
	}
}
