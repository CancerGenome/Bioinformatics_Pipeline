#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./cosmic2chrpos.pl  
#
#  DESCRIPTION:  Cosmic data format to chr pos file, input format shoudle : gene, aa change
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  05/02/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();
my ($pos,$snp);

while(<>) {
    chomp;
    split;
    if ($_[1] =~ /(\d+)([ACGT])\>[ACGT]/) {
        $pos = $1;
        $snp = $2;
        $snp = uc($snp);
        my @list = `tabix ~/db/anno/hg18.map.pos.sort.gene.pos.gz $_[0]:$pos-$pos | grep -w CDS`;
        foreach my $list (@list) {
            chomp $list;
            my @a = split/\s+/,$list;
            my $fa=`samtools faidx ~/db/human/hg18.fa $a[3]:$a[4]-$a[4] | tail -n1`;
            chomp $fa;
            $fa =uc($fa);
            if($a[1] eq "-") {
                $snp=~ tr/ACGT/TGCA/
            }
            if ($fa eq $snp) {
                print "$list\t$fa\n";
            }
        }
    }
}

