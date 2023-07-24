#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  Cut 1-4 pileup > annotation -> give coverage
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  05/11/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

my ($last_gene,$last_chr,$last_pos,$total,$length);
my (%start);

while(<>) {
    next if(!/CDS/);
    chomp;
    my @F = split;

    $start{$F[5]} = $F[1] if (not defined $start{$F[5]});
    $last_gene = $F[5] if (not defined $last_gene);

    if ( $last_gene ne $F[5] ) {
        print "$last_gene\t$last_chr\t$start{$last_gene}\t$last_pos\t$total\t$length\n";
        $total = $F[3];
        $length = 1 ;
    }

    elsif($last_gene eq $F[5]) {
        $total += $F[3];
        $length ++;
    }

    $last_gene = $F[5];
    $last_chr = $F[0];
    $last_pos = $F[1];
}
        print "$last_gene\t$last_chr\t$start{$last_gene}\t$last_pos\t$total\t$length\n";
