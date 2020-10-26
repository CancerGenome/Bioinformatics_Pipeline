#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  Filter Position changes -c <columns keep diff> -n <max_diff> -k <columns keep same> -
# 
#  DESCRIPTION:  Filter number changes line by line
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  01/11/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use Getopt::Std;

our($opt_c,$opt_n,$opt_k);
$opt_n = 0;
getopts("c:n:k:");
&usage if (!$opt_c);
$opt_c -- ;
$opt_k -- ;

my ($current, $last, $last_num, $last_keep_num);
my (@current);


while($current = <> ) {
    chomp $current;
    @current = split/\s+/, $current ;
    if ( $opt_k ) {

        if( defined $last_num && (abs($current[$opt_c] - $last_num ) > $opt_n || $current[$opt_k] != $last_keep_num) ) {
            print "$last\n";
        }
    }

    elsif ( abs($current[$opt_c] - $last_num ) > $opt_n && defined ($last_num)) {
        print "$last\n" ;
    }
    $last_num = $current[$opt_c];
    $last_keep_num = $current[$opt_k];
    $last = $current;
}
