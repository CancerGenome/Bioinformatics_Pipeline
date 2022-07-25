#!/usr/bin/perl 
sub usage() {
    die qq(
#===============================================================================
#
#        USAGE:  ./get_dep.pl  <IN> <Dep file> <window size> <Chr_field:1> <Pos_field:2>
#
#  DESCRIPTION:  Given a file and get its depth of window 
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  2010年04月19日 
#===============================================================================
)
}
use strict;
use warnings;

$ARGV[2]||&usage();

my $chrF = $ARGV[3]|| 1;
my $posF = $ARGV[4]|| 2;
my $win  = $ARGV[2];

$chrF -- ;
$posF -- ;

my %hash;

open IN , "$ARGV[0]"|| die;
while(<IN>){
    chomp;
    split/\,/;
    next if ($_[$posF] !~ /[1-9]/);
    #print "$_[1]\n";
    $_[$posF] = (int($_[$posF]/$win)+1)*$win;
    #print "$_[1]\n";
    $hash{$_[$chrF]}{$_[$posF]} = $_;
}

open IN2,"$ARGV[1]"||die;
while(<IN2>) {
    chomp;
    split;
    if ($hash{$_[$chrF]}{$_[$posF]}) {
        print "$hash{$_[$chrF]}{$_[$posF]}\t$_\n";
    }
}


