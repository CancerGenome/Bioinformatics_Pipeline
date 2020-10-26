#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:prepare_for_annovar.pl  -h
#        DESCRIPTION: -h : Display this help
#        For single association *.combine only
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 30 Nov 2018 02:02:35 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

while(my $line = <>){
	chomp $line;
	my @F= split/\s+/,$line;
	next if ($F[0] eq "ID");
	my @G = split/[:_\/]/,$F[0];
	#print $#G,"\n";
	if($#G eq 4){
		print "$G[0]\t$G[1]\t$G[4]\t$G[2]\t$G[3]\t100\tPASS\t$F[0]\tGT\t0/1\n";
	}
	if($#G eq 3){
		print "$G[0]\t$G[1]\t-\t$G[2]\t$G[3]\t100\tPASS\t$F[0]\tGT\t0/1\n";
	}
}

