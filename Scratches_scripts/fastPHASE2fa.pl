#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:trans.fastPHASE.out.pl  -h
#        DESCRIPTION: -h : Display this help
#        -p : output phased haplotype for haploview
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 03 Jan 2019 03:31:58 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_p);
getopts("hp");

my $index = 0 ;

while(my $line = <>){
	chomp $line;
	if ($line eq "BEGIN GENOTYPES"){
		$index = 1;
		next;
	}
	if($line eq "END GENOTYPES"){
		next;
	}
	if($index ==1 ){
		my $id = $line;
		$id =~s/\#//;
		$id =~s/\s//;
		$id = ">".$id;
		my $seq1 = <>;
		my $seq2 = <>;
		$seq1 =~s/\s//g;
		$seq2 =~s/\s//g;
		my $id2 = $id."_2";
		if(defined $opt_p){
			$id =~ s/>//;
			$seq1 =~ tr/ACGTN/12340/;
			$seq2 =~ tr/ACGTN/12340/;
			my @F =split//,$seq1;
			my @G =split//,$seq2;
			print "$id $id ", join(" ",@F),"\n";
			print "$id $id ", join(" ",@G),"\n";
		}else{
			print "$id\n$seq1\n$id2\n$seq2\n";
		}
		#print "$id\t$seq1\n$id2\t$seq2\n";
	}
}
