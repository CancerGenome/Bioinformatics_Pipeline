#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:phase_output2fa.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 11 Jan 2019 11:45:08 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my $marker = 0; 

while(my $line= <>) {
	chomp $line;
	if($line eq "BEGIN BESTPAIRS1"){
		$marker = 1;
		next;
	}
	if($line eq "END BESTPAIRS1"){
		$marker = 0;
		next;
	}
	
	if($marker == 1 ){
		my @F = split/\s+/,$line;
		my @G = split/\_/,$F[1];
		my $id = $G[1];

		my $seq1 = <>;
		my $seq2 = <>;

		chomp $seq1;
		chomp $seq2;
		
		$seq1 =~ s/\s//g;
		$seq1 =~ s/[\(\)]//g;
		$seq2 =~ s/\s//g;
		$seq2 =~ s/[\(\)]//g;

		#$seq1 = substr($seq1,0,41);
		#$seq2 = substr($seq2,0,41);
		print "\>$id\_1\n$seq1\n\>$id\_2\n$seq2\n";
	}

}
