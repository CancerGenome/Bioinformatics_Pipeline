#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./print_gene_pos_via_map.pl  
#
#  DESCRIPTION:  Provide a Map file and print all gene position and chr position
#                Example : TP53  12  chr17 7******
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/26/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

while(<>) {
    chomp;
    my ($gene,$chr,$strand,$geneS,$geneE,$cdsS,$cdsE,$exonCount,$exonS,$exonE) =  split;
    #print $exonS,"\t",$exonE,"\n";
    my @exonS = split/\,/,$exonS;
#    push (@exonS,$cdsS);
#    @exonS = &uniq(@exonS);
    my @exonE = split/\,/,$exonE;
#    push (@exonE,$cdsE);
#    @exonE = &uniq(@exonE);

#    foreach (@exonE) {$_--};  #remove zero base influence
#    foreach (@exonS) {$_--};
#    $cdsS -- ;
#    $cdsE -- ;

#    print join("\t",@exonS),"\n";
#    print join("\t",@exonE),"\n";
    my $last_pos = 0;

    if ($strand eq "+" ) {
        my $l = 1 ;
        my $anno  = "CDS";

        for my $i(0..$#exonS) {
            for my $j($exonS[$i]..$exonE[$i]) {
                if ($j < $cdsS){
                    $anno = "UTR-5";
                }
                elsif ($j > $cdsE){
                    $anno = "UTR-3";
                }
                elsif($j >=$cdsS && $j <=$cdsE) {
                    $anno = "CDS";
                }
                else {
                    $anno ="Null";
                }

                $l = 1 if ($j== $cdsS || $last_pos == $cdsE);
                print "$gene\t$strand\t$l\t$chr\t$j\t$anno\n";
                $l ++;
                $last_pos = $j;
            }
        }

    }

    elsif ($strand eq "-" ) {
        my $anno  = "CDS";
        my ($utr5,$utr3,$cdslength) = qw(0 0 0);
        for my $i(0..$#exonS) {
            for my $j($exonS[$i]..$exonE[$i]) {
                if ($j < $cdsS) {
                    $utr3++;
                }
                elsif ($j > $cdsE) { 
                    $utr5++;
                }
                else {
                    $cdslength++;
                }

            }
        }

        my $l = $utr3;

        for my $i(0..$#exonS) {
            for my $j($exonS[$i]..$exonE[$i]) {
                if ($j < $cdsS){
                    $anno = "UTR-3";
                }
                elsif ($j > $cdsE){
                    $anno = "UTR-5";
                }
                elsif($j >=$cdsS && $j <=$cdsE) {
                    $anno = "CDS";
                }
                else {
                    $anno ="Null";
                }

                $l = $cdslength if ($j == $cdsS);
                $l = $utr5 if ($last_pos == $cdsE);
                print "$gene\t$strand\t$l\t$chr\t$j\t$anno\n";
                $l --;
                $last_pos = $j;
            }
        }

    }
}

sub uniq (@) {
            my %seen = ();
                grep { not $seen{$_}++ } @_;
}
