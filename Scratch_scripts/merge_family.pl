#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./merge.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  06/25/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();
open IN,"$ARGV[0]";
my ($last,$last_num,$last_total,$last_freq,$cur,$num,$total,$freq);
&read();
&update();

while(1) {
    &read();
    if ($cur eq $last) {
        #print "ADD\t$last\t$last_num\t$last_total\t$last_freq\n";
        $num += $last_num;
        $total += $last_total;
    }
    else {
        print "$last\t$last_num\t$last_total\t",int($last_num/$last_total*100)/100,"\n";
    }
        &update();
}


sub read() {
    my $a = <IN>;
    if ($a eq "") {
        print "$last\t$last_num\t$last_total\t",int($last_num/$last_total*100)/100,"\n";
        last;
    }
    chomp $a;
    my @a = split/\s+/,$a;
    $num = $a[5];
    $total = $a[6];
    $freq = $a[7];
    $cur = join("\t",@a[0..4]);

}
sub update() {
    $last = $cur;
    $last_num = $num;
    $last_total = $total;
    $last_freq = $freq;
}
