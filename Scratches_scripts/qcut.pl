#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./qcut.pl  
#
#  DESCRIPTION:  :-c [cut field] -n [add number]
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/18/2012 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;

$ARGV[0] || &usage();
our ($opt_c,$opt_n);
getopt("c:n:");

my @num = split/,/,@opt_c;

while(<>) {
    chomp;
    split;

}

