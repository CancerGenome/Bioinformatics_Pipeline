#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./gsea.pl -f  <INPUT> <GMT file from GSEA>
#
#  DESCRIPTION:  -f : field Number, default 1
#                -a : add score field
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  05/22/2013 
#===============================================================================

)
}

use strict;
use warnings;
use Getopt::Std;

$ARGV[2]||&usage();
our($opt_f,$opt_a);
getopts("f:a:");
if(not defined $opt_f){
	$opt_f = 1;
}
$opt_f--;
$opt_a-- if ($opt_a);

my %hash; # record gene
open IN, $ARGV[0];
while(my $line = <IN>){
    chomp $line ;
    my @F = split/\s+/,$line;
    if($opt_a) { 
        $hash{$F[$opt_f]} = $F[$opt_a];
    }
    else {
        $hash{$F[$opt_f]} = 1 ;
    }
}

#open IN1, $ARGV[1];
#open IN1, "/home/junzli_lab/yulywang/db/all.pathway.gmt";
#open IN1, "/home/yulywang/db/gsea/c2.cp.v6.1.symbols.gmt";
open IN1, "/home/yulywang/db/gsea/msigdb.v6.2.symbols.gmt";
while(<IN1>) {
    chomp;
    my @a = split;
    my $name = $a[0];
    my @print=qw{};
    my $num = 0; 
    for my $i(2..$#a) {
        if ($hash{$a[$i]}){
            push(@print,$a[$i]);
            $num += $hash{$a[$i]};
            #print "$a[$i]\t$hash{$a[$i]}\n";
        }
    }
    if ($print[0]) {
        print "$name\t",join("\t",@print),"\t$num\n";
    }
}
