#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./statis_start_point.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  06/02/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();
my @file = <DATA>;
chomp @file;

while(<>) {
    chomp;
    my ($chr,$pos) = (split/\s+/)[0,1];
    foreach my $file (@file) {
        my @reads = `samtools view $file $chr:$pos-$pos | awk '\$5 >= 30' `;
        chomp @reads;
        my (%a);
        my ($total_num,$total_sp,$total_mut,$total_mut_sp)=qw{0 0 0 0};
        foreach my $read (@reads) {
            my @array = split/\s+/,$read;
              $total_num ++;
              $total_sp ++ if ( !$a{$array[9]} );

              if ($read=~/NM:i:(\d)/ && $1>0) {
                $total_mut ++;
                $total_mut_sp ++ if ( !$a{$array[9]} );
              }

              $a{$array[9]} = 1;
        }
        my @cache = split/\//,$file;
        $file = pop(@cache);
        print "$file\t$chr\t$pos\t$total_num\t$total_sp\t$total_mut\t$total_mut_sp\n";

    }
}

__DATA__
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC1-N0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC1-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC2-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC3-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC4-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC6-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC7-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC8-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC9-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC10-N4
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC11-N0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC12-N1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC13-N0
