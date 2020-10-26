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
    next if(/^#/);
    chomp;
    split;
    my $chr = $_[2];
=head
    if ($_[3] eq "-") {
        my $cache = $_[9];
        $_[9] = $_[10];
        $_[10] =  $cache ;
    }
=cut
    my @start = split/\,/,$_[9];
    my @end = split/\,/,$_[10];
#    print "$chr\t$_[9]\n$chr\t$_[10]\n";
    for my $i (0..$#start) {
        $start[$i] -= 5; 
        $end[$i] += 5;
#        print "$chr\t$start[$i]\t$end[$i]\n";
        for my $j ($start[$i]..$end[$i]) {
            print $chr,"\t$j\n";
        }
    }
}


