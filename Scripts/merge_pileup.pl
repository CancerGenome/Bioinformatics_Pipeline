#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./merge_pileup.pl -f all pileup list 
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/03/2011 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;
#$ARGV[0] || &usage();

our($opt_f);
getopt("f:");

my @file = `less -S $opt_f`;
chomp @file;

my %hash; # for record data 
my %ref;

foreach my $file (@file) {
    chomp $file;
    open IN,"$file";
    while(<IN>) {
        chomp;
        split;
        $ref{$_[0]}{$_[1]} = $_[2];
        $_[4] =~ tr/acgt/ACGT/;
        $_[5] =~ tr/acgt/ACGT/;
        $_[6] =~ tr/acgt/ACGT/;

        my %seen;
        $seen{$_[4]} = 1;
        $seen{$_[5]} = 1;
        $seen{$_[6]} = 1;
        #print "$_[4]\t$_[5]\t$_[6]\n";

        $hash{$_[0]}{$_[1]}{$_[4]} += $_[7];
        $hash{$_[0]}{$_[1]}{$_[5]} += $_[8];
        $hash{$_[0]}{$_[1]}{$_[6]} += $_[9];

        if ($_[6] ne "-") {
             my @base = qw(A C G T);
             my @base1 = grep { not $seen{$_} } @base; # remove seen data
                $hash{$_[0]}{$_[1]}{$base1[0]} += ( $_[3] - $_[8] - $_[9] - $_[7] );
        }
    }
}


        foreach my $key( keys %hash) {
            foreach my $keys (sort {$a <=> $b || $a cmp $b} keys %{$hash{$key}} ) {
                    my @base = qw(A C G T);
                    my @dep = @ {$hash{$key}{$keys}} {@base}; # get dep from hash array 
                    my @idx = sort {$dep[$b] <=> $dep[$a]} grep {$base[$_] ne $ref{$key}{$keys} } qw(0 1 2 3); # remove reference
                    #print join("\t",@base[@idx]),"\n";

                    my $total_dep;

                    foreach(@dep){
                        $total_dep += $_;
                    }
                    print "$key\t$keys\t$ref{$key}{$keys}\t$total_dep\t$ref{$key}{$keys}\t$base[$idx[0]]\t$base[$idx[1]]\t$hash{$key}{$keys}{$ref{$key}{$keys}}\t$dep[$idx[0]]\t$dep[$idx[1]]\n";

            }
        }
