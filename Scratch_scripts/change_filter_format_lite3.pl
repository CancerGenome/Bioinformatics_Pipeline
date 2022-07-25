#!/usr/bin/perl
use warnings;
my (@a,@b,@c);
my $tag = 0;

while(<>){
    @a= qw{};
    chomp;
    split;
    if ($_[0] eq "[A]") {
        $tag = 1;
        for my $i (1..12){
            print $_[$i],"\t";
        }
    }
    if ($_[0] eq "[B]") {
        $tag = 2;
        print "$_[1]\t$_[2]\t$_[3]\t0\t-\t-\t0\t0\t0\t0\t0\t0\t";
        for my $i (4..12){
            print $_[$i],"\t";
        }
    }
    if ($_[0] eq "[C]") {
        $tag = 3;
        print "$_[1]\t$_[2]\t$_[3]\t0\t-\t-\t0\t0\t0\t0\t0\t0\t";
        print "0\t-\t-\t0\t0\t0\t0\t0\t0\t";
        for my $i (4..12){
            print $_[$i],"\t";
        }
        print "\n";
        next;
    }
    if (not defined $_[13]) {
        if ($tag == 1) {
            print "0\t-\t-\t0\t0\t0\t0\t0\t0\t" ;
            print "0\t-\t-\t0\t0\t0\t0\t0\t0\n" ;
        }
        elsif ($tag ==2 ) {
            print "0\t-\t-\t0\t0\t0\t0\t0\t0\n" ;
        }
        next;
    }
    if ($_[13] eq "[B]") {
        $tag = $tag * 10 + 2;
        for my $i (17..25){
            print $_[$i],"\t";
        }
    }
    if ($_[13] eq "[C]") {
        $tag = $tag * 10 +3;
        print "0\t-\t-\t0\t0\t0\t0\t0\t0\t" if ($tag == 2);
        for my $i (17..25){
            print $_[$i],"\t";
        }
        print "\n";
        next;
    }
    if (not defined $_[26]) {
        if ($tag%10==2) {
            print "0\t-\t-\t0\t0\t0\t0\t0\t0\n" ;
            next;
        }
    }
    if ($_[26] eq "[C]") {
        for my $i (30..38){
            print $_[$i],"\t";
        }
        print "\n";
        next;
    }

}
