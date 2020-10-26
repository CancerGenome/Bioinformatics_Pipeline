#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/change_header.pl  -h
#        DESCRIPTION: -h : Display this help
#        Specifically design for header change for RNASeq Ped STAR Mapping
#
#        This has been abandon because of some logic issue, can not fix nine samples
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 01 Nov 2019 05:29:06 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $i = 0 ;

while(my $line = <>){
	$i++;
	chomp $line;
	my @F = split/\s+/,$line;
	if($i == 29){
		print "\@CO\tREFID:Homo_sapiens_assembly19\n\@CO\tANNID:gencode.v19\n";
	}elsif($i == 30 and $F[0] eq "\@RG"){ # fixing old errors
		my $SM = $F[1];
		$SM =~ s/ID/SM/;
		print $F[0],"\t",$F[1],"\t",$SM,"\n";
	}elsif($i == 31 and $F[0] eq "\@RG"){
		my @G = split/\\t/,$F[1];
		print $F[0],"\t",$G[0],"\t",$G[1],"\n";  # new error for nine samples
	}else{
		print $line,"\n";
	}
}
