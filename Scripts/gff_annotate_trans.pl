#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./get.pl  
#
#  DESCRIPTION:  This program translate gff file to commom readable file
#                 This file input have three addition columes at head, so handle your file first
#                 This input was created from select_from_gff.pl             
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/23/2009 
#===============================================================================

          )
}
use strict;
use warnings;
$ARGV[0] || &usage();
my ($curChr,$curPos);
my $print;
while(<>){
    chomp;
    next if ($_ eq "");
    split;
    if ($_[0]=~/chr/) {
        $curChr = $_[0];
        $curPos = $_[1];
        next;
    }
    if (/aID=(.+?);/) {
        $print =  "$curChr\t$curPos\t$1\t";
    }
    my $tag= $_[6];
    if (/solid/){
        $print .= "$_[3]\t$_[4]\t$tag\t";
    }
    if (/s=(.*);/){
        $print .= "$1\t";
        my $a = $1;
        $a  =~ s/s=//;
#---- Print all snp
#---- Single error
        while ($a=~/a(\d+)/g){
                if ($tag eq "+"){
                    my $cache = $_[3]+$1-1;
                    print "$print\t";
                    print "A\t$cache\n";
                }
                elsif ($tag eq "-"){
                    my $cache = $_[4]+1-$1;
                    print "$print\t";
                    print "A\t$cache\n";
                }
            }
#---- Unvalidate double error        
        while ($a=~/b(\d+),b(\d+)/g){
                if ($tag eq "+"){
                    my $cache = $_[3]+$1-1;
                    print "$print\t";
                    print "B\t$cache\n";
                }
                elsif ($tag eq "-"){
                    my $cache = $_[4]+1-$1;
                    print "$print\t";
                    print "B\t$cache\n";
                }
            }
#---- validate single snp
        while ($a=~/g(\d+),g(\d+)/g){
                if ($tag eq "+"){
                    my $cache = $_[3]+$1-1;
                    print "$print\t";
                    print "G\t$cache\n";
                }
                elsif ($tag eq "-"){
                    my $cache = $_[4]+1-$1;
                    print "$print\t";
                    print "G\t$cache\n";
                }
            }    
#---- validated double snp
        if ($a=~/y(\d+),y(\d+),y(\d+)/){
                if ($tag eq "+"){
                    my $cache = $_[3]+$1;
                    print "$print\t";
                    print "$cache\n";
                    $cache = $_[3]+$2;
                    print "$print\t";
                    print "$cache\n";
                }
                elsif ($tag eq "-"){
                    my $cache = $_[4]+1-$1;
                    print "$print\t";
                    print "$cache\n";
                    $cache = $_[4]+1-$2;
                    print "$print\t";
                    print "$cache\n";
                }
            }    
#---- validate three snp
        if ($a=~/r(\d+),r(\d+),r(\d+),r(\d+)/){
                if ($tag eq "+"){
                    my $cache = $_[3]+$1;
                    print "$print\t";
                    print "$cache\n";
                    $cache = $_[3]+$2;
                    print "$print\t";
                    print "$cache\n";
                    $cache = $_[3]+$3;
                    print "$print\t";
                    print "$cache\n";
                }
                elsif ($tag eq "-"){
                    my $cache = $_[4]+1-$1;
                    print "$print\t";
                    print "$cache\n";
                    $cache = $_[4]+1-$2;
                    print "$print\t";
                    print "$cache\n";
                    $cache = $_[4]+1-$3;
                    print "$print\t";
                    print "$cache\n";
                }
            }    
        
#    if (/r=(.*?);/){
#        print $1,"\t";
#    }
#    if (/g=(.*?);/){
#        print "\t",$1;
#    }
    }

    print "\n";
}
