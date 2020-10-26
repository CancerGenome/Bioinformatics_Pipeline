#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./count_read_family.pl  <INPUT>
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  06/21/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();
open IN, "$ARGV[0]";
my($last_id,$last_chr,$last_pos,$last_pos2,$last_barcode,$last_md) = qw{};
my($id,$chr,$pos,$pos2,$barcode,$md) = qw{};
my ($total) = 1;
my (@record) = ((0)x97);
my ($cache_pos,$last_num) = qw{0 0} ;
&read();
&update();
while($md =~ /(\d+)/g) {
        $cache_pos = $1 + $last_num;
        $record[$cache_pos] ++ ;
        #print "Pos\t$cache_pos\n";
        $last_num = $cache_pos + 1 ;
}


while(1) {
    &read();
    $last_num = 0 ;
    $cache_pos = 0 ;
#    print "STAT\t$chr\t$pos\t$pos2\t$barcode\n";
#    print "$last_chr\t$last_pos\t$last_pos2\t$last_barcode\n";
    if ( $barcode eq $last_barcode && $last_chr eq $chr && $last_pos eq $pos && $last_pos2 eq $pos2){
        $total ++;
        while($md =~ /(\d+)/g) {
            $cache_pos = $1 + $last_num;
            $record[$cache_pos] ++ ;
            #print "Pos\t$cache_pos\n";
            $last_num = $cache_pos + 1 ;
        }
    }
    else {
         &print();
         $total = 1;
         @record = ((0)x97);
         # print "STAT\n";
        while($md =~ /(\d+)/g) {
            my $cache_pos = $1 + $last_num;
            $record[$cache_pos] ++ ;
            #print "Pos\t$cache_pos\n";
            $last_num = $cache_pos + 1 ;
        }
    }
    &update;
}

sub read(){
    $_ = <IN>;
    chomp;
    if ($_ eq "") {
        &print();
        last;
    }
    ($id,undef,$chr,$pos,undef,undef,undef,$pos2) = split/\s+/,$_;
    #print "POS$pos\n";
    my @cache_barcode = split/\_/,$id;
    $barcode = join("_",@cache_barcode[1..$#cache_barcode]);
    if (/MD:Z:([\dA-Z]+)/) {
        $md = $1;
        #print "STAT\t$id\t$chr\t$pos\t$pos2\t$1\n";
    }
    else {
        print "$id\t$chr\t$pos\t$pos2\tNo_MD\n";
        next;
    }
}

sub update(){
    $last_id = $id;
    $last_chr = $chr;
    $last_pos = $pos;
    $last_pos2 = $pos2;
    $last_barcode = $barcode;
    $last_md = $md;
}

sub print() {
        $record[0] = 0 if (!$record[0]);
        print "$last_barcode\t$last_chr\t$last_pos\t$last_pos2\t",$last_pos,"\t$record[0]\t$total\t",int($record[0]/$total*100)/100,"\n";
    for my $j (1..96) {
        print "$last_barcode\t$last_chr\t$last_pos\t$last_pos2\t",$last_pos+$j,"\t$record[$j]\t$total\t",int($record[$j]/$total*100)/100,"\n" if ($record[$j] ne 0);
    }
}
