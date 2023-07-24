#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./quickfilter.pl  
#
#  DESCRIPTION:  Index hash for first file and, got quick filter, this allow for small file query
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/15/2010 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();


