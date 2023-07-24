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
#      CREATED:  05/08/2010 
#===============================================================================

)
 }
 use strict;
 use warnings;
 $ARGV[0] || &usage();

 my $fh;
 open($fhw[0], "gzip -dc $ARGV[0]|") || die;

