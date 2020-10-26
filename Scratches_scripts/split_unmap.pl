#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./split.pl  - OUTPUT_NAME
#
#  DESCRIPTION:  common usage
#                samtools view map_bam/ACATAGT.bam | awk 'NF==11' | split_unmap.pl - ACATAGT.bam.unmap
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  02/28/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[1] || &usage();

=head
`rm $ARGV[0].fifo` if -e "$ARGV[0].fifo";
system ("mkfifo $ARGV[0].fifo");
`samtools view $ARGV[0] | awk 'NF==1' > $ARGV[0].fifo &`;

open IN,"$ARGV[0].fifo";
=cut

open OUT1,">$ARGV[1].1";
open OUT2,">$ARGV[1].2";

open IN, "$ARGV[0]";
while(<IN>) {
    chomp;
    split;
    my ($id,$seq,$qua) = @_[0,9,10]; # HWUSI-EAS762_0042:1:1:6443:2435#0
    $id =~ s/HWUSI-EAS//g;
    $id =~ s/\#0/_/g;

    $id .= substr($seq,20,33);

    select OUT1;

    print "\@$id/1\n";
    print substr($seq,0,20),"\n";
    print "+\n";
    print substr($qua,0,20),"\n";

    select OUT2;
    print "\@$id/2\n";
    my $a = reverse substr($seq,53,30);
    $a =~ tr/ACGT/TGCA/;
    print $a,"\n";
    print "+\n";
    print reverse substr($qua,53,30) ;print "\n";
}

close OUT1;
close OUT2;

open SH, ">$ARGV[1].sh";

print SH <<EOF;
bwa aln -t 4 ~/db/human/hg19 $ARGV[1].1 > $ARGV[1].1.aln
bwa aln -t 4 ~/db/human/hg19 $ARGV[1].2 > $ARGV[1].2.aln
bwa sampe -a 10000 -o 1000 ~/db/human/hg19 $ARGV[1].1.aln $ARGV[1].2.aln $ARGV[1].1 $ARGV[1].2 | samtools view -bt ~/db/human/hg19.fa.fai -T ~/db/human/hg19.fa - > $ARGV[1].bam
samtools sort $ARGV[1].bam $ARGV[1].sort
samtools index $ARGV[1].sort.bam
EOF

`qsub.pl $ARGV[1].sh`;
