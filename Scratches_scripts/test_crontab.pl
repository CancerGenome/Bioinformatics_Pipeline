#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./test_crontab.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/28/2010 
#===============================================================================

)
            }
            use strict;
            use warnings;
            $ARGV[0] || &usage();

Test whether crontab
