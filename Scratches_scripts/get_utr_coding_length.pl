#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:get_utr_coding_length.pl  -h
#        DESCRIPTION: -h : Display this help
#        Given Gene list, first column is gene name
#        STDOUT: gene UTR5 length, Coding length, UTR3 length
#        STDERR: all coding bed file
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 21 Sep 2020 03:06:27 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

print "Gene\tUTR5\tCoding\tUTR3\n";
while (my $line = <>){
    chomp $line;
    my @F = split/\s+/,$line;
	my $gene = $F[0];
	`rm cache`;
	`echo $gene > cache`;
	my $utr3 = `fetch.pl -q1 -d4 cache /home/yulywang/db/anno/hg19_RefSeq_RefFlat.clean.bed | grep utr3 | sumbed.sh - `;
	my $coding = `fetch.pl -q1 -d4 cache /home/yulywang/db/anno/hg19_RefSeq_RefFlat.clean.bed | grep -w cds | sumbed.sh - `;
	my @coding = `fetch.pl -q1 -d4 cache /home/yulywang/db/anno/hg19_RefSeq_RefFlat.clean.bed | grep -w cds `;
	my $utr5 = `fetch.pl -q1 -d4 cache /home/yulywang/db/anno/hg19_RefSeq_RefFlat.clean.bed | grep utr5 | sumbed.sh - `;
	chomp ($utr3, $coding, $utr5);
	if($utr3 eq ""){
		$utr3 = 0;
	}
	if($utr5 eq ""){
		$utr5 = 0;
	}
	if($coding eq ""){
		$coding = 0;
	}
	print $line,"\t$utr5\t$coding\t$utr3\n";
	foreach my $coding (@coding){
		chomp $coding;
		print STDERR "$coding\t$gene\tCDS_Bed\n";
	}
}
