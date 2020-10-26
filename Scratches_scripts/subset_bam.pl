#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:subset.pl  -h (required two files as input)
#        # pos.list: chr start end
#        # bam.list: Full path bam file
#        # More convenient way: 
#        samtools view -O BAM -o OUTPUT.bam INPUT.bam `perl -ane '{print "$F[0]:$F[1]-$F[2] "}' INPUT.bed `
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 22 Jan 2020 03:48:42 PM STD
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my @POS;
open POS, "pos.list";
while(my $line = <POS>){
	chomp $line;
	my @F = split/\s+/,$line;
	push(@POS, $F[0].":".$F[1]."-".$F[2] );
}
close POS;
my $pos = join(" ",@POS);

my $i = 0 ; # use for controlling the file numbre limitation
open BAM, "bam.list";
while(my $line = <BAM>){
	chomp $line;
	my @F = split/\//,$line;
	my $prefix = $F[$#F];
	#next if ($i>=1);
	`samtools view -O BAM -o $prefix.bam $line $pos`;
	`samtools index $prefix.bam`;
	$i++;
}


