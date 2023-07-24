#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./trans_stats2.pl  <-> -n (change A,G to number)
#
#  DESCRIPTION:  Input : three columns, A, G , 120
#                Format to 4 div 4 table
#                -n :  4  9  120 ...
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  01/10/2012 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();


our ($opt_n);
getopts("n:");
my @base =qw{A C G T};
if ($opt_n) {
    @base = 0..$opt_n;
}
my %hash;

while(<>){
    chomp;
    split;
    $hash{$_[0]}{$_[1]} = $_[2];
}

print "From\\To\t",join("\t",@base),"\n";
foreach my $a (@base) {
       print $a,"\t";
    foreach my $b (@base) {
       if ( $hash{$a}{$b} ) {
            print $hash{$a}{$b},"\t"; 
       }
       else {
           print "0\t";
       }
    }
    print "\n";
}
