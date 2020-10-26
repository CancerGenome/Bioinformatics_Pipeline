#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./rmOverlapRegion.pl
#                -f : filed of position,  default : 4 
#                -d : field of position2, default: 5
#                -h : display this hlep
#
#  DESCRIPTION:  Remove all adjacent error, input file must be sorted and remove duplication
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/15/2010 
#===============================================================================

)
            }
use strict;
use warnings;

use Getopt::Std;
our ($opt_f,$opt_h,$opt_d);
$opt_d = 1 ;
getopt("f:hd:");
&usage if ($opt_h);
&usage unless ($ARGV[0]);

my ($last,$last2)=qw(0 0);
my $fie = $opt_f || 5 ;
my $fie2 = $opt_f || 6 ;
$fie -- ;
$fie2 -- ;

open IN, $ARGV[0];

    my ($l,@a) ;
    $l = <IN>;
    chomp $l;
    @a = split/\s+/,$l;
    &upd();

while(1) {
    if ( $a[$fie]-$last <= $opt_d && $a[$fie]-$last > 0 ) {
            &upd(); # both of them are removed,
            #        print "StepI: $lastL\t$l\n";
            &upd();
            #print "StepII: $lastL\t$l\n";
    }
    else {
        print "$lastL\n";
        &upd();
    }
}

sub upd (){

    if (eof(IN)) {
        print "$l" if !( $a[$fie]-$last <= $opt_d && $a[$fie]-$last > 0 );
        last;
    }
    else {
        $last = $a[$fie];
        $last2 = $a[$fie2];
        $l = <IN>;
        chomp $l;
        @a = split/\s+/,$l;
    }
}
