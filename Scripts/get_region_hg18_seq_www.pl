#!/usr/bin/perl
sub usage (){
    die qq(
#===============================================================================
#PROBLEM: abondon
#        USAGE:  ./generate_refseq.pl <Refseq from Ucsc> <Path include each_chr.fa>
#
#  DESCRIPTION:  For Refseq data, generate a dataset for annotation. Output for each chromosome
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/09/2010
#===============================================================================
)
}

use strict;
use warnings;
$ARGV[0] || &usage();

my $path = $ARGV[1] || '/share/disk7-3/wuzhygroup/ruanjue/genomes/hg18/';
my $input = $ARGV[0];
my $current_chr = q{};
my $ref = q{};
my $seq = q{};

open IN, "$input";
while(<IN> ){
    chomp;
    my (undef,$name_id,$chr,$strand,$txStart,$txEnd,$cdsStart,$cdsEnd,$exonCount,$exonStart,$exonEnd,undef,$gene,$start_com,$end_com,$frame) = split;         #____ start_com means start codon is complete or not, frame (-1 means no exon)
    my @exonStart = split/,/,$exonStart;
    my @exonEnd = split/,/,$exonEnd;
    my $line = $_ ;
#---- update reference
=mask for no reference
    if ($current_chr ne $chr){
        $ref = q{};
        if (-e "$path/$chr.fa"){
        open IN2,"$path/$chr.fa";
        while(<IN2>){
            next if (/^>/);
            chomp;
            $ref .= $_;
        }
    }
    #   print "$chr\t",length($ref),"\t",substr($ref,0,918),"\n";
    }
    next if ($ref eq q{});# ignore abnormal chr

if ( $start_com eq "cmpl" and $end_com eq "cmpl" ){
    for my $i (0..$exonCount-1){
        next if ($exonEnd[$i] < $cdsStart or $exonStart[$i] > $cdsEnd);
        my ($s,$e);
        ($exonStart[$i] >= $cdsStart ) ? ($s = $exonStart[$i] ) : ($s = $cdsStart);
        ($exonEnd[$i] <= $cdsEnd ) ? ($e = $exonEnd[$i]) : ($e = $cdsEnd );
            $seq .=  substr($ref,$s,$e-$s);
    }
}
else {
    $seq = '-';
}
=cut
        $gene = uc($gene);
        $seq = uc($seq);
        if ($strand eq '-') {
            $seq =~ tr/ACGT/TGCA/;
            $seq = reverse $seq;
        }
        $seq = "-"; # add tempor
        $txStart ++;
        $cdsStart ++; # for 0-base in UCSC
        print
        "$gene\t$chr\t$strand\t$txStart\t$txEnd\t$cdsStart\t$cdsEnd\t$exonCount\t$exonStart\t$exonEnd\t$seq\t$name_id\t$start_com\t$end_com\n";
# ----- update
    $seq = q{};
    $current_chr  = $chr;
    }
