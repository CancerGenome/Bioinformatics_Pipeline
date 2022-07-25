#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/bcftools_stats_print_insertion_deletion.pl  -h
#        DESCRIPTION: -h : Display this help
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

print "Filename\tInsertion\tDeletion\tRatio\n";
print "$ARGV[0]\t";

my $insertion = 0 ;
my $deletion = 0 ;
while(my $line = <>){
	chomp $line;
	if($line =~ /^IDD/){
		my @F = split/\s+/,$line;
		if($F[2]<0){
			$deletion += $F[3];
		}elsif($F[2]>0){
			$insertion += $F[3];
		}
	}
}
print "$insertion\t$deletion\t",$insertion/$deletion,"\n";
