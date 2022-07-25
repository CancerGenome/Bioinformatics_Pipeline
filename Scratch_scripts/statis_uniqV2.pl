#!/usr/bin/perl 
sub usage(){
    die qq(
#===============================================================================
#
#        USAGE:  ./statis.pl <STDIN/->
#                -c which column is used for hash, at most two columns, default 1 or (1,2)
#                -s Separator [\s+]
#
#  DESCRIPTION:  Statistics a column or two column ,like sort | uniq -c 
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  06/03/2009 04:57:01 PM
#===============================================================================
)
}
use strict;
use warnings;
use Getopt::Std;

our ($opt_c,$opt_h,$opt_s);
getopt("c:hs:");
&usage if ($opt_h);
&usage unless ($ARGV[0]);
$opt_s = '\s+' unless ($opt_s);

open IN, $ARGV[0];
my @array;
my @col;

if ($opt_c) {
    # multiple option
#    if ($opt_c) {
#        @col = split/\,/,$opt_c;
#        foreach (@col) {
#            $_ -- ;
#        }
#        $tag = $#col + 1;
#    }
}
else {
    my $hash;
    my $tag = 1 ;
    @col=qw(0);

 # ------get  Column numbers ------ 
    my $line = <IN>;
    @array = split/$opt_s/,$line;

    if ($#array == 0 ) {
        $col[0] = 0 ;
    }
    elsif ($#array == 1 ) {
        $col[0] = 0 ;
        $col[1] = 1 ;
        $tag = 2 ;
    }
#    &count($hash,$tag,\@col);
    &count($hash,$tag);

    while(<IN>){
        chomp;
        @array = split /$opt_s/;
#        &count($hash,$tag,\@col);
        &count($hash,$tag);
    }

    &print($hash,$tag);
    }
#-------  print -------------
sub print($$) {

    my $hash = shift;
    my %hash = %{$hash};
    my $tag = shift;

    if ($tag ==1){
        foreach my $key (sort {$a <=> $b || $a cmp $b } keys %hash){
            print "$key\t$hash{$key}\n";
        }
    }
    elsif ($tag ==2){
        foreach my $key (sort {$a <=> $b || $a cmp $b} keys %hash){
            foreach my $keyss (sort {$a <=> $b || $a cmp $b} keys %{$hash{$key}}){
                print "$key\t$keyss\t$hash{$key}{$keyss}\n";
            }
        }
    }
}


sub count($$){
    my $hash = shift;
    my $tag = shift;
#    my @col = @{$_};
    if ($tag == 1 ) {
        $hash->{$array[$col[0]]} ++ ;
    }
    elsif ($tag == 2 ) {
        $hash->{$array[ $col[0] ]} { $array[ $col[1] ]} ++ ;
    }
}
