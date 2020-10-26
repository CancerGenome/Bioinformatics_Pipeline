#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./codon.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/23/2011 
#===============================================================================

)
}
use strict;
use warnings;

my $in;
my %codonMap;

while($in=<DATA>) {
    chomp $in;
    #print "LLL:$in\n";
    my @codon = split " ",$in;
    my $residue = shift @codon;
    foreach my $nnn (@codon) {
        $codonMap{$nnn} = $residue;
        # print "NNN:$nnn\n";
    }
}

while(my $dna=<STDIN>){
    chomp $dna;
    print "DNA: ",$dna,"\n";
    my $protein = &translate($dna);
    print "Protein:$protein\n";
}

sub translate($){
    my $mrna = shift;
    print "MRNA:$mrna\n";
    my $pro = "";
    while($mrna =~ s/(...)//){
#        print "$codonMap{$1}\n";
        print "Now_MRNA:$mrna\n";
        $pro = $pro.$codonMap{$1};
    }
    return $pro;
}

__DATA__
Ala GCU GCC GCA GCG
Arg CGU CGC CGA CGG AGA AGG
Asn AAU AAC
