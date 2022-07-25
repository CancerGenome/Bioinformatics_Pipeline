#!/usr/bin/perl 
sub usage(){
    die qq(
#===============================================================================
#
#        USAGE:  ./test_crontab2.pl  
#
#  DESCRIPTION:  i
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#      COPYRIGHT:  
#      VERSION:  1.0
#      CREATED:  04/28/2010 11:33:35 AM
#===============================================================================
)}

use strict;
use warnings;

$ARGV[0] || &usage();

test whether crontab in ssh8
