#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./SlideWinDepth.pl 
#       OPTION:  -w <Window Size, default: 1000000> 
#                -s <Sliding Overlap Size, default: 0>  
#                -c (Chr Column/1) 
#                -p (Pos Column/2) 
#                -b (Bed Format, use p, p+1 as position,default: 1-base)
#                -d <Depth Column/3>
#                -a (Treat Depth as one) -
#
#  DESCRIPTION:  From Pileup File --> Sliding Windows Read Depth
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/26/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use Getopt::Std;

our($opt_w,$opt_s,$opt_c,$opt_p,$opt_a,$opt_d,$opt_b);
getopts("w:s:c:p:d:ab");
my %hash; # record chrosome information
my $w = $opt_w || 1000000;
my $s = $opt_s || 0;
my $chr_index = $opt_c || 1 ;
my $pos_index = $opt_p || 2 ;
my $pos2_index = $opt_p || 2 ;
my $dep_index = $opt_d || 3 ;
$chr_index -- ;
$pos_index -- ;
$dep_index -- ;

while(<>) {
    chomp;
    my @array = split;
    #next if ($array[3] eq "-" || $array[3] == 0);
	if(defined $opt_b){ # defined bed file
		$pos2_index = $pos_index + 1;  # begin bed format
		#print "Pos_Index:$pos_index\n$pos2_index\n";
	}
	for my $pos($array[$pos_index]..$array[$pos2_index]){
		#print "Pos:",$pos,"\n";
		my @array_pos = &pos2array($pos);
		foreach my $i (@array_pos) {
			if (not defined $opt_a) {
				$hash{$array[$chr_index]}[$i] += $array[$dep_index];
			}
			elsif (defined $opt_a) {
				$hash{$array[$chr_index]}[$i] += 1 ;
			}
		}
	}
}

foreach my $chr (keys %hash) {
    my @a = @{$hash{$chr}};
    for my $i (0..$#a) {
        my @pos = &array2pos($i);
        my $depth = $hash{$chr}[$i] ;
        $depth =0 if (not defined $depth);
        print "$chr\t",join("\t",@pos),"\t$depth\n";
    }
}

sub pos2array() {  # for a given genome position, will (W-S)*N+1 <= Pos <= (W-S)*N +W;
    # array position will be N <= (pos-1)/(W-S) && N >= (pos-W)/(W-S)
    my $pos = shift;
    my $n1 = ($pos-$w)/($w-$s);
    my $n2 = ($pos-1)/($w-$s);
    if ($n1 < 0 ) {
        $n1 = 0 ;
    }
    elsif ($n1 == int($n1)) {
        $n1 = int($n1);
    }
    elsif ($n1 != int($n1)) {
        $n1 = int($n1) + 1 ;
    }
    my @return = ($n1..int($n2));
    #print "Line\t$pos\t",join("\t"),@return,"\n";
    return (@return);
}
sub array2pos() { # for a given array position, Coving genome position is (W-S)*N+1 ---- (W-S)*N + W;
    my $array =  shift;
    my @return;
    $return[0] = (($w-$s) * $array + 1);
    $return[1] = (($w-$s)*$array + $w);
    return (@return);
}
