#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./quickget.pl  
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
$ARGV[0] || &usage();
my @cache = <DATA>;
chomp @cache;
while(<>) {
    chomp;
    my @a = split;
#    print @a;
    foreach (@cache) {
        chomp;
#        print "samtools view $_ $a[0]:$a[1]-$a[1] | samtools pileup -Sf ~/db/human/hg18.fa - | pileup_inf_rj.pl - |awk '\$2==$a[1]' \n" ;
        my $a = `samtools view $_ $a[0]:$a[1]-$a[1]|samtools pileup -Sf /share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa - | /share/disk7-3/wuzhygroup/wangy/bin/pileup_inf_rj.pl - |awk '\$2==$a[1]'` ;
        print "$_\t$a\n";
    }

}
__DATA__
HCC10-D6
HCC10-N4
HCC10-TC
HCC11-N0
HCC11-T1
HCC11-T2
HCC12-N1
HCC12-T1
HCC12-T3
HCC13-N0
HCC13-T1
HCC13-T2
HCC1-N0
HCC1-N1
HCC1-R1
HCC1-R2
HCC1-T0
HCC2-N1
HCC2-T1
HCC3-N1
HCC3-T1
HCC4-N1
HCC4-T1
HCC6-N1
HCC6-T1
HCC7-N1
HCC7-T1
HCC8-N1
HCC8-T1
HCC9-N1
HCC9-T4
HCC9-T9
