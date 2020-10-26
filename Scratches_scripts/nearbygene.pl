#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  -h
#        DESCRIPTION: -h : Give Chr, Start and End automatically output genes within this region
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 24 May 2019 09:20:19 AM EDT
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
	my $chr = "chr$F[0]";
	if($F[0] =~/chr/){
		$chr = $F[0];
	}
	my $pos1 = $F[1];
	my $pos2 = $F[2];
	open OUT, ">/tmp/input.bed";
	print OUT "$chr\t$pos1\t$pos2\n";
	close OUT;
	my @query = `bedtools intersect -a /tmp/input.bed -b ~/db/anno/hg19.refseq.bed -wa -wb| cut -f7| sort -u | xargs`;
	print $line,"\t",@query;
}

__DATA__
8	27094255
16	28617338
21	33641251
15	43785099
3	47454399
3	47454399
6	50681817
1	57284773
5	70837260
10	131639306
2	228771831
