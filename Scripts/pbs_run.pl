#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./print_pbs.pl <INPUT> 
#
#  DESCRIPTION:  Print PBS head file and others
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/25/2009 
#===============================================================================

		  )
}
use strict;
use warnings;

$ARGV[0]|| &usage();
open OUT,">$ARGV[0].sh";
print OUT <<EOF;
#!/bin/sh
#PBS -N www_$ARGV[0]
#PBS -o /share/disk6-4/wuzhy/wangy/tmp/$ARGV[0].out
#PBS -e /share/disk6-4/wuzhy/wangy/tmp/$ARGV[0].err
#PBS -q bioque
EOF

open IN,"$ARGV[0]";
while(<IN>)
{
	print OUT;	

}
`qsub $ARGV[0].sh`;
`mv $ARGV[0].sh $ARGV[0]`;
