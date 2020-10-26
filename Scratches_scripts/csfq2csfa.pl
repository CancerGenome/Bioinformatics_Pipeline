#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./csfq2csfa.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/29/2010 
#===============================================================================

)
            }
use strict;
use warnings;
$ARGV[0] || &usage();

while(<>){
    if (/^\@chr1_(\d+)_(\d+)_(.+)\/(\d)/) {
        print ">$1_$2_$3_";
        ($4 == 1 ) ? (print "F3\n") : (print "R3\n");
    }
    my $line = <>;
    <>;
    <>;
    $line =~ tr/ACGTN/0123./;
    print "T0$line";
}
