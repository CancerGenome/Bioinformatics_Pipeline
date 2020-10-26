#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./getRestrictionEnzymeSite.pl   "Restriction Enzyme" "chr"
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  06/08/2013 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

my $path     = "/leofs/wuzhy_group/ruanjue/disk7-3/genomes/hg18";
my $res_enzyme = shift;
my $chr = shift;

my @chr = <DATA>;
my $seq = '';
chomp @chr;

#foreach my $chr(@chr){
    open(FA, "$path/$chr\.fa") or die("$path/$chr\.fa");
        $seq = '';
        while(<FA>){
            next if(/^>/);
            chomp;
            $seq .= $_;
        }
        close FA;
        &getSite($res_enzyme,$seq,$chr);
#}

sub getSite($$$){
    my $res_enzyme = shift ;
    my $seq = shift ;
    my $chr = shift;

    my $res_enzyme_r = reverse($res_enzyme);
    $res_enzyme_r =~ tr/ATCGatcgn/TAGCtagcn/;

    $res_enzyme =~ tr/atcg/ATCG/;
    $seq =~ tr/atcg/ATCG/;

    while($seq =~ /$res_enzyme/gi) {
        print "$res_enzyme\t$chr\t$-[0]\t$+[0]\n";
    }
    while($seq =~ /$res_enzyme_r/gi) {
        print "$res_enzyme_r\t$chr\t$-[0]\t$+[0]\n";
    }
}

__DATA__
chr1
chr2
chr3
chr4
chr5
chr6
chr7
chr8
chr9
chr10
chr11
chr12
chr13
chr14
chr15
chr16
chr17
chr18
chr19
chr20
chr21
chr22
chrX
chrY
