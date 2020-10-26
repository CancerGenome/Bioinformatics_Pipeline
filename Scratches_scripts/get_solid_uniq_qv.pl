#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./get_solid_uniq_qv.pl  
#
#  DESCRIPTION:  get solid uniq mapping QV distribution, compare with maq result
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  03/30/2009 03:50:35 PM
#===============================================================================

use strict;
use warnings;
$ARGV[0] || die ("\n\t\tperl $0 <INPUT>\n\n");
my %hash;
open IN1, "$ARGV[0]";
while(<IN1>){
if(/uniq/){
split;
$hash {$_[0]} =1;
}
}
close IN1;
my %qua;
open IN, "/share/disk3/solid/data/Indica/Rawdata/BIG_S069_20081213_2_rif_F3_QV.qual";
#open IN, "cache.qv.txt";
while (<IN>) {
chomp;
if (/^>/) {
$_ =~ s/>//;
#print $_,"\n";
if (exists $hash{$_}) {
my $sline = <IN>;
chomp $sline;
my @array = split /\s+/,$sline;
foreach (@array){
my $null = (exists $qua{$_})? ($qua{$_}++) : ($qua{$_}=1);
}
}
}
}

foreach my $key (keys %qua){
print "$key\t$qua{$key}\n";

}
