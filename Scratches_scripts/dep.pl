#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./c.pl  
#
#  DESCRIPTION:   Depth data per 1k windows
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/29/2010 
#===============================================================================

)
}
use strict;
use warnings;

my $chr = 'chr1';
my @dep;
my $dep  = 1000;

while(1) {
    $_ = <>;
    if (not defined $_){
        &print;
        last;
    }
    chomp;
    split;
    if ($_[0] eq $chr) {
        $dep[int($_[1]/$dep)+1] += $_[3];
    }
    elsif ($_[0] ne $chr) {
        &print;
        @dep = qw{};
        $dep[int($_[1]/$dep)+1] += $_[3];
        $chr = $_[0];
    }
}
sub print(){
    for my $i (0..$#dep) {
        (not defined $dep[$i]) ? ($dep[$i] = 0) : 1;
        print $chr,"\t",1000*($i+1),"\t",$dep[$i],"\n";
    }
}

