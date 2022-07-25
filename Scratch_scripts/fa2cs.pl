#!/usr/bin/perl
use strict;
use warnings;

#---- color space matrix
my %trans;
$trans{'A'}{'A'}= 0;
$trans{'C'}{'C'}= 0;
$trans{'G'}{'G'}= 0;
$trans{'T'}{'T'}= 0;

$trans{'A'}{'C'}= 1;
$trans{'A'}{'G'}= 2;
$trans{'A'}{'T'}= 3;

$trans{'C'}{'A'}= 1;
$trans{'C'}{'G'}= 3;
$trans{'C'}{'T'}= 2;

$trans{'G'}{'A'}= 2;
$trans{'G'}{'C'}= 3;
$trans{'G'}{'T'}= 1;

$trans{'T'}{'A'}= 3;
$trans{'T'}{'C'}= 2;
$trans{'T'}{'G'}= 1;


$ARGV[0]|| die "\t\tperl $0 <INPUT> <Size/40> <Step/10>";
$ARGV[1]|| ($ARGV[1]=40);
$ARGV[2]|| ($ARGV[2]=10);

open IN, "$ARGV[0]";
#open OUT, ">read.fq";
open QV, ">qv";
my $seq="";
while(<IN>){
	chomp;
	next if (/^>/);
	$seq .= $_;
}

my $length = length($seq);
my $count =1;
for my $i (1..$length ){
	if ($i%$ARGV[2]==0){
#	print OUT "@",int($i/$ARGV[2]),"/1\n";	
		
	my @array = split//,substr($seq,$i,$ARGV[1]);
	print ">$count\_$count\_$count\_F3\nT";
	print QV ">$count\_$count\_$count\_F3\n";
	$count ++;
	my $last ="T";
	foreach(@array){
		print $trans{$last}{$_};
		$last = $_;
		print QV "40 ";
	}
	print "\n";
	print QV "\n";
#print OUT "+\n";
	for my $j (1..$ARGV[1]){
#	print OUT "I"
	}
#	print OUT "\n";
	}

}

