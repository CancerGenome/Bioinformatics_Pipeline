#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  print_upstream.pl <*.map> -s <1000> -p <+/->
#
#  DESCRIPTION:  print upstream default 1000 size
#                print which strand
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  11/23/2012 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();

our($opt_s,$opt_p);
getopts("s:p:");
my $size = $opt_s || 1000 ;
my ($left,$right) = qw{};

while(<>) {
    chomp;
    split;
    my $strand = $_[2];
    if ($strand eq "+" && $strand eq $opt_p) {
        $left = $_[3] - $size;
        $right = $_[3] - 1;
    }
    elsif ($strand eq "-" && $strand eq $opt_p) {
        $left = $_[4] - $size;
        $right = $_[4] - 1;
    }
    print "$_[0]\t$_[1]\t$_[2]\t$left\t$right\t$left\t$right\t1\t$left\t$right\n" if ($left!=0 && $right!=0);

    $left = 0 ;
    $right = 0 ;
}
