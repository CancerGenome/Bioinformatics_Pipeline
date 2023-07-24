#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/Transpos.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        mail: wangyu.bgi\@gmail.com
#        Created Time:  Fri, Jul 24, 2015  4:16:22 PM
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $NF = `tail -n1 $ARGV[0] | awk '{print NF}'`;
chomp $NF;
$NF=$NF-1;

# open file handle for printing
my @fh=qw{};
for my $i(0..$NF){
	open ($fh[$i],">/tmp/XXX$i") || die;
}

open IN, $ARGV[0];
while(my $line = <IN>){
	chomp $line;
	next if ($line =~ /^#/);
	my @F = split/\s+/,$line;
	die if ($#F ne $NF);
	for my $i(0..$NF){
		select $fh[$i];
		print $F[$i];
		if(eof(IN)){
			print "\n";
		}
		else{ 
			print "\t";
	}

	}
}

`rm /tmp/combine` if (-e "/tmp/combine");
for my $i(0..$NF){
	close $fh[$i];
	`cat /tmp/XXX$i >> /tmp/combine`;
	`rm /tmp/XXX$i`;
}
