#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./SumForSame  -c (compare which columns,multiple) -f (add column)
# 
#  DESCRIPTION:  Add gap for with different value
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  07/14/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use Getopt::Std;

our($opt_c,$opt_f);
getopts("c:f:");
&usage if (!$opt_c);
my @col = split/\,/,$opt_c;
foreach (@col) {
    $_ -- ;
}
$opt_f --;

$_ = <> ;
chomp;
@_ = split;
my @last =  @_[@col];
my $sum = $_[$opt_f];

while(<>) {
    chomp;
    split;
    for my $i (0..$#col) {
        if ($last[$i] ne $_[$col[$i]]) {
            print join("\t",@last),"\t",$sum,"\n";
            $sum = 0; 
            last;
        }
    }
    $sum = $sum + $_[$opt_f];
    @last = @_[@col];
#    print "$_\n";
}

    print join("\t",@last),"\t",$sum,"\n";
