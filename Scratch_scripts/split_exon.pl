#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./split_exon.pl  
#
#  DESCRIPTION:  spilt cds to one single exon, change gene name
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/21/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

while(<>) {
    chomp;
    split;
    my @start = split/\,/,$_[8];
    my @end = split/\,/,$_[9];
    for my $i (0..$#start) {
        my @print;
        push(@print,$_[0]."_".($i+1),$_[1],$_[2],$start[$i],$end[$i],$start[$i],$end[$i],1,$start[$i],$end[$i]);
        print join("\t",@print),"\n";
    }
}

