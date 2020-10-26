#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./pileup_bwa_inf.pl  <INPUT / - > <Filter Quality : default 0>
#
#  DESCRIPTION:  Get information from pileup file and filter low quality
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/30/2009 04:51:51 PM
#===============================================================================
          )
}
use strict;
use warnings;

$ARGV[0] || &usage();
my $cut_quality = $ARGV[1] || 1;

    my %base=('C' => 1,'G' => 2,'T' => 3,'A' => 0, 1 => 'C', 2=> 'G', 3=> 'T', 0
        => 'A',',' => 4, '.' => 4, 'N' => 4);
    my @head_print = qw(#Chr Pos Ref Depth 1st 2nd 1stFre 2ndFre A C G T);
        print join("\t",@head_print),"\n";
    
while(<>){
    chomp;
    next if ($_ eq "") ; 
    split; # chr pos ref consen consen_quality snp_quality max_map_quality seq seq_quality
    next if ($_[2] eq "*") ; # omit indel 
    my ($chr,$pos,$ref,undef,undef,undef,undef,undef,$seq,$qua) = @_;
    $ref = uc ($ref);

#    print "$_\n";
#------ remove others
    my ($tag,$dep,$last_num,$p) = qw(0 0 0 0) ;
    my @count = qw(0 0 0 0 0);
    for my $i (0..length($seq)-1) {
        my $a = substr($seq,$i,1);
#       print "Sec\t$p\t$a\t$tag\n";
        if ($last_num) {
            if ($a=~/[1-9]/) {
                $tag = $tag * 10 + $a ; # default only two num
            }
            else {
                $last_num = 0;
            }
        }

        if ($last_num ==0 and $tag > 0 ) { 
            $tag -- ;
            next;
        }
        #print "$last_num\t$tag\t$p\t$a\t$tag\n";

        if ($a eq '^' ) {
            $tag = 1;
        }
        elsif ($a eq '$' or $a eq '+' or $a eq '-') {}

        elsif ($a =~ /[1-9]/) {
                $tag = $a;
                $last_num = 1 ;
        }
        elsif ($a eq "*") {
            $p ++;
        }
        else {
            #print STDERR $p,"$a\t$tag\n";
            if (ord( substr ($qua,$p,1)) -33  >= $cut_quality ) {
                #    print STDERR ord(substr ($qua,$p,1))-33,"\n";
                $count[$base{uc($a)}] ++ ;
                $dep ++ ;
                #print "First\t$a\n";
            }
            $p ++;
        }
    }
        $count[$base{uc ( $ref ) }] += $count[4];
        pop @count;
        my @rank = sort {$count[$b] <=> $count[$a] }(0,1,2,3);
        my ($fir,$sec,$firA,$secA) = qw{- - 0 0};
        if ($dep) {
            $fir = $base{$rank[0]};
            $sec = $base{$rank[1]} if ($count[$rank[1]] > 0);
            $firA = int($count[$rank[0]]/($dep+0.000001)*1000+0.5)/1000;
            $secA = int($count[$rank[1]]/($dep+0.000001)*1000+0.5)/1000;
            if ($fir ne $ref and $count[$base{$ref} ] == $count[$base{$fir} ]) {
                print
                "$chr\t$pos\t$ref\t$dep\t$ref\t$fir\t$firA\t$firA\t",join("\t",@count),"\n";
            }
            else {
                print
                "$chr\t$pos\t$ref\t$dep\t$fir\t$sec\t$firA\t$secA\t",join("\t",@count),"\n";
            }
        }
}

