#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  Print first and second allele and remove adjacent error
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/01/2010 
#===============================================================================

)
            }
use strict;
use warnings;
$ARGV[0] || &usage();
my @a = qw(8 17 26);
my @b = qw(A C G T);
my %base=('C' => 1,'G' => 2,'T' => 3,'A' => 0, 1 => 'C', 2=> 'G', 3=> 'T', 0
        => 'A',',' => 4, '.' => 4);
my ($last,$last_p) = qw{};
my @last_rec = qw{0 0 0};

    while(<>) {
        chomp;
        split;
#        print $_[1],"\n";
        my @count;
        my $cur;
        my @rec = qw(0 0 0);
        foreach my $i (@b) {
            foreach my $j (@a) {
                my $jl = $j + $base{$i};
                $count[$base{$i}] += $_[$jl];
            }
        }
        #print join("\t",@count);
        #print "\n";
        my @rank = sort {$count[$b] <=> $count[$a]}(0,1,2,3);
        #print join("\t",@rank);
        #print "\n";
        $cur =  "$base{$rank[0]}\t$base{$rank[1]}\t";
        my $cache = 0;

#----- remove last adjacent error
        foreach my $k (@a) {
            my $k0 = $k + $rank[0];
            my $k1 = $k + $rank[1];
            $rec[$cache] = 1 if ($_[$k1]);
            $cache ++;
            $cur .= "$_[$k0]\t$_[$k1]\t";
        }
        $cur .=  "$_\n";

        for my $i (0..2) {
            if ($last_p - $_[1] == -1) {
                if ($rec[$i] > 0 && $last_rec[$i] > 0) {
                   print STDERR $last;
                   print STDERR $cur;
                   $last_p = $_[1];
                   @last_rec = @rec;
                   $last = qw{};
                   last;
                }
            }
        }
        if (not defined $last) {
            $last = $cur;
            $last_p = $_[1];
            @last_rec = @rec;
            next;
        }
        print $last;
        $last = $cur;
        $last_p = $_[1];
        @last_rec = @rec;
    }
=head
        $count[$base{'A'}] = $_[8]+$_[17]+$_[26];
        $count[$base{'C'}] = $_[9]+$_[18]+$_[27];
        $count[$base{'G'}] = $_[10]+$_[19]+$_[28];
        $count[$base{'T'}] = $_[11]+$_[20]+$_[29];
        print join("\t",@count);
        print "\n\n\n";
