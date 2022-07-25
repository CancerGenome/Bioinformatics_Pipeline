#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./print_mpileup.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  07/19/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

my $win= 100000000;
my $j = 0; 
open DATA,"/share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa.fai";
while(<DATA>) {
    chomp;
    split;
    for my $i (0..int($_[1]/$win) ) {
        $j++ ;
        print $_[0],"\t",$i*$win+1,"\t";
        if ($i == int($_[1]/$win) ) {
            print $_[1],"\t$j\n";
        }
        else {
            print $i*$win+$win,"\t$j\n";
        }

    }
}
