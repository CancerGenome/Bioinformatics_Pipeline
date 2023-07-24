#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/bcftools_stats_print_insertion_deletion.pl  -h
#        DESCRIPTION: -h : Display this help
#        Translate BCFtools stat results and output below results:
#        Name: Total SNPs SNPs% Indels Indels% TsTV Ins Del Ins/Del
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 20 Feb 2020 12:37:12 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

print "Procedure\tTotal\tSNP\tSNP%\tIndel\t%Indels\tTsTV\tIns\tDel\tIns/Del\n";
print "$ARGV[0]\t";

my ($total,$SNPs, $indels, $TSTV, $insertion, $deletion) = qw{};

while(my $line = <>){
	chomp $line;
	if($line =~/^SN.+records/){
		my @F = split/\s+/,$line;
		$total = $F[$#F];
	}
	if($line =~/^SN.+SNPs/){
		my @F = split/\s+/,$line;
		$SNPs = $F[$#F];
	}
	if($line =~/^SN.+indels/){
		my @F = split/\s+/,$line;
		$indels = $F[$#F];
	}
	if($line =~/^TSTV/){
		my @F = split/\s+/,$line;
		$TSTV = $F[4];
	}
	if($line =~ /^IDD/){
		my @F = split/\s+/,$line;
		if($F[2]<0){
			$deletion += $F[3];
		}elsif($F[2]>0){
			$insertion += $F[3];
		}
	}
}

print "$total\t$SNPs\t",int($SNPs/$total*1000)/10,"%\t$indels\t",int($indels/$total*1000)/10,"%\t$TSTV\t$insertion\t$deletion\t",int($insertion/$deletion*1000)/10,"%\n";
