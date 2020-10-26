#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./xargs.pl -i <Shell command> -n <Which line should be processed> - (STDIN,must have)
#
#  DESCRIPTION:  Translate to xargs accept
#      EXAMPLE:  echo "chr1" | xargs.pl -i print.sh - | sh > multi.sh
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  01/08/2012 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;
our ($opt_i,$opt_n);
getopts("i:n:");

$ARGV[0] || &usage();

my $line = `sed -n '$opt_n,$opt_n p' $opt_i`;
#$line =~ s/\\/\\\\/g;
$line =~ s/\"/\\\"/g;
$line =~ s/\$/\\\$/g;
chomp $line;

while(<>) {
    chomp;
    print "echo $_ | xargs -i echo \" $line \" \n";
}
