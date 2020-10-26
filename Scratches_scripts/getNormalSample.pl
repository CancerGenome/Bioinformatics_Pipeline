#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./quickget.pl  <STDIN>
#                -r replace your list with file, file format: full path bam,0(if solid),1(if solexa)
#                -q Base Quality [30]
#                   solid calculation:  33 + quality * 2
#                   solexa calculation: 33 + 31 + quality 
#                -m Map Quality [30]
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/28/2011 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;

$ARGV[0] || &usage();

our($opt_r,$opt_q,$opt_m);
getopts('r:q:m:');
my @cache = <DATA>;
@cache = `less $opt_r` if ($opt_r); # replace you file with original
#print STDERR "$opt_q\t$opt_m\n";
$opt_q = 30 if (not defined $opt_q);
$opt_m = 30 if (not defined $opt_m);
#print STDERR "$opt_q\t$opt_m\n";
chomp @cache;
my $i = 0;

    foreach my $cache (@cache) {
        my @array = split/\s+/,$cache;
        my $filter_quality = 31 * $array[1] + $opt_q * ( 2- $array[1]);
        my $file = $array[0];

        my @out;
        @out = `/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -f /share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa -Bq $opt_m -l $ARGV[0] $file | pileupTools -f $filter_quality - | fetch.pl -q1,2 -d1,2 $ARGV[0] -`;
        foreach my $out (@out) {
            chomp $out;
            my @a = split/\//,$file;
            print pop(@a),"\t$out\n";
        }
}

#        print "samtools view $_ $a[0]:$a[1]-$a[1] | samtools pileup -Sf ~/db/human/hg18.fa - | pileup_inf_rj.pl - |awk '\$2==$a[1]' \n" ;
        #my @a = `less $ARGV[0] | awk '{ print "samtools view $cache "\$1":"\$2"-"\$2} ' `;
        #my @a = `less $ARGV[0] | awk '{ print "samtools view $cache "\$1":"\$2"-"\$2} '| sh | msort -kb3,n4 | awk '\$5 >=30 '| uniq | samtools pileup -Sf /share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa - | /share/disk7-3/wuzhygroup/wangy/bin/pileup_inf_rj.pl -sf 30 - | fetch.pl -q1,2 -d1,2 $ARGV[0] -` ;

__DATA__
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC1-N0 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC1-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC2-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC3-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC4-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC6-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC7-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC8-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC9-N1 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC10-N4 0
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC11-N0 1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC12-N1 1
/share/disk7-3/wuzhygroup/wangy/allhcc/bam/HCC13-N0 1
