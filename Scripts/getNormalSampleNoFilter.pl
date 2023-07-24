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
#push(@cache,qw{HCC11-TA HCC11-TC HCC11-TF HCC11-TG HCC11-TH HCC11-TJ});
#@cache=qw{HCC11-N0 HCC11-TA HCC11-TC HCC11-TF HCC11-TG HCC11-TH HCC11-TJ};
chomp @cache;

#    print @a;
    foreach my $cache (@cache) {
        chomp $cache;
#        print "samtools view $_ $a[0]:$a[1]-$a[1] | samtools pileup -Sf ~/db/human/hg18.fa - | pileup_inf_rj.pl - |awk '\$2==$a[1]' \n" ;
        #my @a = `less $ARGV[0] | awk '{ print "samtools view $cache "\$1":"\$2"-"\$2} ' `;
        #my @a = `less $ARGV[0] | awk '{ print "samtools view $cache "\$1":"\$2"-"\$2} '| sh | msort -kb3,n4 | awk '\$5 >=30 '| uniq | samtools pileup -Sf /share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa - | /share/disk7-3/wuzhygroup/wangy/bin/pileup_inf_rj.pl -sf 30 - | fetch.pl -q1,2 -d1,2 $ARGV[0] -` ;
        my @a = `samtools pileup -f /share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa -l $ARGV[0] $cache | /share/disk7-3/wuzhygroup/wangy/bin/pileup_inf_rj.pl - | fetch.pl -q1,2 -d1,2 $ARGV[0] -` ;
        foreach my $a (@a) {
            chomp $a;
            print "$cache\t$a\n";
        }
}
__DATA__
HCC1-N0
HCC1-N1
HCC2-N1
HCC3-N1
HCC4-N1
HCC6-N1
HCC7-N1
HCC8-N1
HCC9-N1
HCC10-N4
HCC11-N0
HCC12-N1
HCC13-N0
