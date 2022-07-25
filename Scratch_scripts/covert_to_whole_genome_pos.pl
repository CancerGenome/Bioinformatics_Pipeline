#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./covert_to_whole_genome_pos.pl <INPUT>  <Fa.Fai>
#                -c: chromosome field
#                -p: pos field
#                -h: skip header
#
#  DESCRIPTION:  covert your local pos to whole genome position
#                fa.fai should be generate by samtools faidx
#                chromosome should be chr1,chr2 etc.
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/09/2014 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;

our ($opt_c,$opt_p,$opt_h);
getopts("c:p:h"); # thus can get argument for i and boolen for h
$ARGV[0] || &usage();
$ARGV[1] || &usage();

my $chr_field = ($opt_c  ) ||  1 ; 
my $pos_field = ($opt_p  ) ||  2 ; 
$chr_field -- ;
$pos_field --;

open FA,"$ARGV[1]";
my %hash; # for chr total pos
while(<FA>){
    chomp;
    split;
    $hash{$_[0]} = $_[2];
}

open IN, "$ARGV[0]";
if ($opt_h){
    $_=<IN>;
    print "Genome\tAccumuPos\t$_";
}
while(<IN>){
    chomp;
    split;
    print "Genome\t",$hash{$_[$chr_field]}+$_[$pos_field],"\t";
    print join("\t",@_),"\n";
}
