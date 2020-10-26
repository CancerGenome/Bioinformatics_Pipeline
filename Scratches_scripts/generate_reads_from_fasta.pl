#!/usr/bin/perl
use warnings;
use strict;

$ARGV[0]|| die "\t\tperl $0 <INPUT> <Size/40> <Step/10>";
$ARGV[1]|| ($ARGV[1]=40);
$ARGV[2]|| ($ARGV[2]=10);

open IN, "$ARGV[0]";
my $seq="";
while(<IN>){
	chomp;
	next if (/^>/);
	$seq .= $_;
}
my $length = length($seq);
for my $i (1..$length ){
	if ($i%$ARGV[2]==0){
	print "@",int($i/$ARGV[2]),"/1\n";	
	print substr($seq,$i,$ARGV[1]),"\n";	
	print "+\n";
	for my $j (1..$ARGV[1]){
	print "I"
	}
	print "\n";
	}

}

