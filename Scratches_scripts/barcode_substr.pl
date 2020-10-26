#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/24/2010 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

while(<>) {
    print;
    print STDERR;
    $_ = <>;
    chomp;
    print substr($_,0,7),"\n";
    print STDERR substr($_,7,75),"\n";
}
