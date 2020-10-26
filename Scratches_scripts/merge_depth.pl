#!/usr/bin/perl 
sub usage() {die qq{
#===============================================================================
#
#        USAGE:  ./depth_merge.pl <->  <Window size (1000)>
#
#  DESCRIPTION:  Merge depth , treat default first and sec as chr and pos
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  2010年04月09日 
#===============================================================================
}}

use strict;
use warnings;

$ARGV[0] || &usage();
my $win = $ARGV[1] || 1000;
my ($chr,$pos,$chrL,$posL,$line);
my (@in) = qw {} ;
my ($chr_pos,$pos_pos) = qw (0 1);
my ($index,$count)= qw (1 0) ;
my %hash;

#---- Initialize
open IN, $ARGV[0];
&readin();
$chrL = $in[$chr_pos];
    for my $i($pos_pos+1..$#in) {
        $hash{$i} = 0;
    }
#print "$chr\t$chrL\n";
while(1) {
    if ($chr eq $chrL) {
        while($index * $win < $pos) {
            &print();
            $index ++;
        }
#        print $index,"\n";
        if (int(($pos - 0.5)/$win) == $index -1 ) { # avoid marginal effect
            &add_num(); 
            &readin();
        }
    }
    elsif ($chr ne $chrL) {
        &print;
        $index = 1;
        $chrL = $chr;
    }
    if (eof(IN)){
        &print();
        last;
    }
}


sub readin() {
    $chrL = $chr;
    $posL = $pos;
    $line  = <IN>;
    chomp $line;
    @in = split/\s+/,$line;
    $chr = $in[$chr_pos];
    $pos = $in[$pos_pos];
}

sub add_num() {
    for my $i($pos_pos+1..$#in) {
        $hash{$i} += $in[$i];
    }
}

sub print() {
    print "$chrL\t",$index*$win,"\t";
    for my $i($pos_pos+1..$#in) {
        print "$hash{$i}\t";
        $hash{$i} = 0;
    }
    print "$index\n";
}
