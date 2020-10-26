#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:prepare_for_annovar.pl  -h -s
#        DESCRIPTION: -h : Display this help
#        -s: standard input chr pos ref, alt
#
#        if without any parameters, for RNASeq prepartion
#
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
our ($opt_h,$opt_s);
getopts("hs");

my @H = `cat ~/bin/VCF_Header`;
my $last = pop(@H);
my @F = split/\s+/,$last;
print @H;
print join("\t",@F),"\n";

while(my $line = <>){
	chomp $line;
	my @F= split/\s+/,$line;
	next if ($F[0] eq "chr");
	$F[0] =~ s/chr//;
	if(defined $opt_s){
		print "$F[0]\t$F[1]\t.\t$F[2]\t$F[3]\t100\tPASS\t.\tGT\t0/1\n";
	}else{
		print "$F[0]\t$F[1]\t.\t$F[2]\t$F[3]\t100\tPASS\tDP=$F[5];ALTCOUNT=$F[6];TISSUE=$F[7];SAMPLE=$F[8];SUBJECT=$F[9]\tGT\t0/1\n";
	}
}

#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT
#chr	pos	ref	alt	context	coverage	alt_count	tissue	sample_id	subject_id
#chr1	25451781	G	A	TTGGG	57	8	Adipose_Subcutaneous	03105	129
