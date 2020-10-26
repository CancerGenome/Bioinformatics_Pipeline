#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./MultipleAverage.pl -a (which columns) -n (Sliding Size)
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  10/25/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use Getopt::Std;
our($opt_a,$opt_n);
getopts("a:n:");

my @field = split/\,/,$opt_a;
foreach (@field) {
    $_ --; 
}

my @record;
my $num = 0;

while(<>) {
    chomp;
    my @array = split/\s+/,$_;
    $num ++;
    for my $i(0..$#field) {
        $record[$i] += $array[$field[$i]] ;
    }
    if ($num == $opt_n) {
        print join("\t",@record),"\n";
        $num = 0 ;
        @record =qw{};
    }
}
