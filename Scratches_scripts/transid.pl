#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./transid.pl <HGNC> <Biomart Data/Lite>
#
#  DESCRIPTION:  Merge hgnc id and Biomart output(ENSG,ENST,ENSP,Hgncid,Gene Symbol)
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/20/2010 
#===============================================================================

)
}
use strict;
use warnings;

my @p = qw{0 1 10 17 18 23 28 35 36};

open HGNC, "hgnc_full";
open BIO, "mart_export.lite";

my %hash1;
my %hash2;
while(<BIO>) {
    chomp;
    split;
    push(@{$hash1{$_[3]}},$_[1]);
    push(@{$hash2{$_[3]}},$_[2]);
}
close BIO;

my $header = <HGNC>;
my @header = split/\t/,$header;
foreach my $p(@p) {
    $_ = $header[$p];
   s/\s+/_/g;
   print;
   print "\t";
}
print "Ensembl_transcript_id\tEnsembl_protein_id\n";

while(<HGNC>) {
    chomp;
    my @a = split/\t/,$_;

    foreach my $p(@p) {
        $a[$p] =~ s/\s+//g;
        print $a[$p],"\t" if ($a[$p] ne "");
        print "-\t" if ($a[$p] eq "");
    }

    $a[0] =~s/HGNC://g;
#    print "$a[0]\t";
    if ($hash1{$a[0]} && $hash2{$a[0]}){
        print join(",",&uniq( @{$hash1{$a[0]}} ) ),"\t",join(",",&uniq( @{$hash2{$a[0]}} ) );
    }
    else {
        print "-\t-";
    }

    print "\n";
}
close HGNC;

sub uniq (@) {
        my %seen = ();
            grep { not $seen{$_}++ } @_;
        }
