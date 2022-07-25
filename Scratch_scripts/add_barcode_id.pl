#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./add_barcode_id.pl  <FQ1> <FQ2> <Barcode> 
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  06/20/2012 
#===============================================================================

)
}
use strict;
use warnings;
use FileHandle;
$ARGV[0] || &usage();

my ($fq1,$fq2,$qua1,$qua2,$id1,$id2,$barcode_id,$barcode,$sample_barcode);
open FQ1, "$ARGV[0]";
open FQ2, "$ARGV[1]";
open BQ, "$ARGV[2]";
my $i = 1;
my %handle;

open IN, "barcode.list";
while(<IN>) {
    chomp;
    split;
    my $fh1 = FileHandle->new(" | gzip > $_[1]\_1.gz");
    my $fh2 = FileHandle->new(" | gzip > $_[1]\_2.gz");
    $handle{$_[0]}{"1"} = $fh1;
    $handle{$_[0]}{"2"} = $fh2;
}

while(1) {
  &fq1();
  &fq2();
  &barcode();
  if ( $id1 eq $id2 && $id1 eq $barcode_id && $id1 ne "") {
      if ( $handle{$sample_barcode}{"1"}) {
            my $fh = $handle{$sample_barcode}{"1"};
            print $fh "\@$i\_$barcode\n$fq1\n+\n$qua1\n";
            $fh  = $handle{$sample_barcode}{"2"} ;
            print $fh "\@$i\_$barcode\n$fq2\n+\n$qua2\n";
       }
       else {
            my $fh = $handle{"ELSE"}{"1"};
            print $fh "\@$i\_$sample_barcode\_$barcode\n$fq1\n+\n$qua1\n";
            $fh = $handle{"ELSE"}{"2"};
            print $fh "\@$i\_$sample_barcode\_$barcode\n$fq2\n+\n$qua2\n";
       }
        $i ++ ;
  }
  else {
    print "$id1\t$id2\t$i\n";
    last;
  }
}

sub fq1(){
    my $cache = <FQ1>;
    chomp $cache; last if ($cache eq "");
    my @id = split/\s+/,$cache;
    $id1 = $id[0];
    $fq1 = <FQ1>;
    <FQ1>;
    $qua1 = <FQ1>;
    chomp ($id1,$fq1,$qua1);
}
sub fq2(){
    my $cache = <FQ2>;
    chomp $cache; last if ($cache eq "");
    my @id = split/\s+/,$cache;
    $id2 = $id[0];
    $fq2 = <FQ2>;
    <FQ2>;
    $qua2 = <FQ2>;
    chomp ($id2,$fq2,$qua2);
}
sub barcode(){
    my $cache = <BQ>;
    my @id = split/\s+/,$cache;
    $barcode_id = $id[0];
    $cache = <BQ>;
    $sample_barcode = substr($cache,0,6);
    $barcode = substr($cache,6,8);
    <BQ>;
    <BQ>;
    chomp ($barcode_id,$barcode);
}
