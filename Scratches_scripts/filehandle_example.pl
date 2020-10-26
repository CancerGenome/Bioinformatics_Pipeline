#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./sel_sam.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/26/2009 10:03:26 PM
#===============================================================================

		  )
}
use strict;
use warnings;
use FileHandle;
my $fh = FileHandle->new;

while(<>) {
    chomp;
    split;
    $fh->open(">> $_[0]");
    print $fh $_,"\n";
}
