#!/usr/bin/perl -w
#
#Author: Ruan Jue<ruanjue@genomics.org.cn>

use warnings;
use strict;

my $seq_file = shift or die("Usage: $0 <fasta_file> [seq_len:100]\n");
my $seq_len  = shift || 100;

my $doc = '';
my $seq = '';

my $in;
if($seq_file eq'-'){
	$in = \*STDIN;
} else {
	open($in, $seq_file) or die($!);
}

while(<$in>){
	if(/^>/){
		my $line = $_;
		if($doc and length($seq) >= $seq_len){
			print "$doc\n";
			while($seq=~/(.{1,60})/g){ print "$1\n"; }
		}
		chomp $line;
		$doc = $line;
		$seq = '';
	} else {
		chomp;
		$seq .= $_;
	}
}
if($doc and length($seq) >= $seq_len){
	print "$doc\n";
	while($seq=~/(.{1,60})/g){ print "$1\n"; }
}
close $in if($seq_file ne '-');
