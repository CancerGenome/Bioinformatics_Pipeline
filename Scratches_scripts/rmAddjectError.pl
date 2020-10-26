#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./rmAddjectError.pl -l -d -p -n file1 file2 [UNFINISHED]
#
#  DESCRIPTION:  for remove PCR-jump sequencing error
#                -l file1 column number, (chr,pos)
#                -d file2 column number, (chr,pos)
#                -p file2 additional column with change (pair-end)
#                -n total difference from all columns, default 2
#                rmAddjectError.pl -l 1,4 -d 1,5 -p 6 -n2 mut.list all.combine
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  02/22/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use GetOpt::Std;
our($opt_l,$opt_d,$opt_p,$opt_n);
getopts("l:d:p:n:")
my @col = split/\,/,$opt_l;
my @col2 = split/\,/,$opt_d;
my %hash;
foreach (@col) {
    $_ --;
}
foreach (@col2) {
    $_ --;
}
$opt_p --;
$opt_n || $opt_n = 2;


open LIST,$ARGV[0];
while(<LIST>){
    chomp;
    split;
    $hash{join("\t",@_[@col])} = 1;
}

my @last; # record last line
open QUERY,$ARGV[1];
while(<QUERY>) {
    chomp;
    next if ($_ eq "");
    split;
    if ($hash{join("\t",@_[@col2])}) {
        my $pos_col = $col2[$#col2];
        my $add_col = $opt_p;
        if ( abs($_[$pos_col] - $last[$pos_col]) + abs ($_[$add_col] - $last[$add_col]) <= $opt_n ) {
        
        }
    }

}
