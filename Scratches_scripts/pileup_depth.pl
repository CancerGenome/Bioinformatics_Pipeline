#!/usr/bin/perl
use warnings;
use strict;

my $last_chr = 'chr1';
my $count = 0 ;
my $window = 1000;
my $index = 0;

open IN , $ARGV[0];
while(<IN>){
    chomp;
    split;

    if ($_[0] eq $last_chr and int($_[1]/$window)== $index) {$count +=$_[3];}
	elsif ($_[0] ne $last_chr ){
        $index ++ ;
        my $cache = $index * $window;
        print "$last_chr\t$cache\t$count\n";
        $index = 0;

        if(int($_[1]/$window)== $index) {$count = $_[3];}
        else {$count = 0;}
    }
    elsif ($_[1]/$window > $index){
        $index ++ ;
        my $cache = $index * $window;
        print "$last_chr\t$cache\t$count\n";

        if (int($_[1]/$window)== $index) {$count = $_[3];}
        else {$count = 0;}
    }
    if (eof(IN)){
        $index ++ ;
        my $cache = $index * $window;
        print "$last_chr\t$cache\t$count\n";
    }
    $last_chr = $_[0];
}

