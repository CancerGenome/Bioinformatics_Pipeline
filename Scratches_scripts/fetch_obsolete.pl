#!/usr/bin/perl
# 2008-3-5

use strict;
# options
use Getopt::Std;
use vars qw($opt_a $opt_b $opt_m $opt_h);
getopts('a:b:m:h');

my $af=defined $opt_a ? $opt_a : 1;
my $bf=defined $opt_b ? $opt_b : 1;
my $md=defined $opt_m ? $opt_m : 1; # md: mode
my $help=$opt_h ? 1 : 0;
my $afile=shift;
my $bfile=shift;

if ($help) {
	usage(); exit;
}
unless (-e $afile) {
	usage(); exit;
}
unless (-e $bfile) {
	usage(); exit;
}


my %ina;
open IN, $afile || die $!;
# fasta afile
if ($af==0) {
	while (<IN>) {
		if (/^>(\S+)/) {
			$ina{$1}=1;
		}
	}
}
elsif ($af > 0) {
	while (<IN>) {
		chomp;
		my @d=split;
		$ina{$d[$af-1]}=1 if (defined $d[$af-1]);
	}
}
else {
	usage(); exit;
}
close IN;

open IN, $bfile || die $!;
# fasta bfile
if ($bf==0) {
	my $flag=0;
	while (<IN>) {
		if (/^>(\S+)/) {
			if ($ina{$1}) {
				$flag=1;
			}
			else {
				$flag=0;
			}
			if ($md==0) {
				$flag=abs($flag-1);
			}
			
			print if ($flag);
		}
		elsif ($flag) {
			print;
		}
	}
}
elsif ($bf > 0) {
	while(<IN>) {
		chomp;
		my @d=split;
		if ($md==0) {
			if (! $ina{$d[$bf-1]}) {print "$_\n"}
		}
		else {
			if ($ina{$d[$bf-1]}) {print "$_\n"}
		}
	}
}
else {
	usage(); exit;
}
close IN;

sub usage{
	my $usage = << "USAGE";
Fetch data from file2, according to an common KEY field in file1.
For fasta format files, sequence identifiers act as the key field.
table like file is delimited by whitespaces and the default key 
field is the first. Field number is counted from 1.

Usage: fetch.pl [options] file1 file2
Options:
  -a <num> the key field of file1,0=fasta identifiers, default=1
  -b <num> the key field of file2,0=fasta identifiers, default=1
  -m <0/1> m=1: fetch data whose key pair with key in file1
           m=0: fetch data whose key can not pair with key in file1
           default: m=1
  -h       display this help
Examples:
  fetch.pl -a 2 -b 1 file1 file2
  fetch.pl -m 0 file1 file2
  fetch.pl -a 2 -b 0 file1 file2(fa)
Author: liqb (BGI.shenzhen)
Please report bugs to <liqb\@genomics.org.cn>
USAGE
	print $usage;
}
