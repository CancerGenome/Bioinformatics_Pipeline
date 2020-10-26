#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./trans_stats.pl  input start[1] end[100] break[10]
#
#  DESCRIPTION:  Translate stats file (triple columns) to availabe format for read
#        INPUT:  Depth\tAnnotation\tNumber : 1\tUTR\t1090
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  11/08/2010 
#===============================================================================

)
}
use strict;
use warnings;
use POSIX;
$ARGV[0] || &usage();

my $start = $ARGV[1] || 1;
my $end = $ARGV[2] || 100;
my $break = $ARGV[3] || 10;
#print "$start\t$end\t$break\n";
my %numh = qw{}; # for count hash record
my %total =qw{};
#my @anno = qw{CDS INTRON UTR-3 UTR-5 INTERGENIC All};
my @anno = qw{CDS};

open IN, $ARGV[0];
while(<IN>) {
    chomp;
    split;
    if($_[0]<=$end) {
        $numh{ceil($_[0]/$break)}{$_[1]} += $_[2];
        $numh{ceil($_[0]/$break)}{'All'} += $_[2];
    }
    else {
        $numh{ceil($end/$break)+1}{$_[1]} += $_[2];
        $numh{ceil($end/$break)+1}{'All'} += $_[2];
    }
    $total{$_[1]} += $_[2];
    $total{'All'} += $_[2];
}

#---- cultivate accumulation for data------
for my $i (sort {$b <=> $a} (1..int($end/$break))) {
#    print "$i\n";
    foreach my $anno(@anno){
#        print "$i\t$anno\t",$numh{$i}{$anno},"\n";
        $numh{$i}{$anno} += $numh{$i+1}{$anno};
    }
}

#---- format print --------
for my $i(ceil($start/$break)..int($end/$break)){
    foreach my $anno(@anno) {
        my $a = $break*$i-($break-1);
        printf("%6s\t",">=$a");
        printf("%10s\t",$anno);
        printf("%8s\t",$numh{$i}{$anno});
        printf("%0.3f\n",$numh{$i}{$anno}/$total{$anno});
    }
}
my $i = ceil($end/$break)+1;
    foreach my $anno(@anno) {
        my $a = $end + 1;
        printf("%6s\t",">=$a");
        printf("%10s\t",$anno);
        printf("%8s\t",$numh{$i}{$anno});
        printf("%0.3f\n",$numh{$i}{$anno}/$total{$anno});
}
