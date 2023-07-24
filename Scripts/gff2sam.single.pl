#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./gff2sam.single.pl  <INPUT> or pipe | gff2sam.pl - 
#
#  DESCRIPTION:  Covert gff to sam , for single-end only
#
#  FILE FORMAT:  Difference with ture SAM file: 
#                1,mapping quality is pairing quality, 
#                2,Tag RQ means read quality by gff, 
#                3,2nd field tag only give paired reads information, 
#                4,One key information: if have single mismatch, invalid
#  double error, trible or bigger error, the quality of site which has error
#  will be set to zero. Eg : position 2 has mismatch in color read, then
#  quality of position 2 and 3 base will be zero. 
#                5,XT: type actually is not so good in gff format
#                6,fix insert size TO DO
#
#       AUTHOR:  wangyu.big at gmail.com, ruanjue at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/17/2010, fix insert - size 
#===============================================================================

)
            }
use strict;
use warnings;
$ARGV[0] || &usage();

my %hash;
my @chr;
my @tmp = qw(aID at b c g o p pq q r rb s u);

while(<>){
#---- chr rec
    if (/^##contig/){
        chomp;
        my @t = split;
        $chr[$t[1]] = qw(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10
            chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21
        chr22 chrX chrY chrM)[$t[1]-1];
    }
    next if(/^##/);
    my $line1 = $_;
    my ($chr1,undef,undef,$start1,$end1,$read_qua1,$strand1,undef,$anno1) =
    split/\s+/,$line1;
    if ($anno1 =~ /i=(\d+)/) {
    $chr1 = $chr[$1] || die ("No Chr info at File Header\n");
    }
    my
    ($id1,$type1,$seq1,$cigar1,$seq_c1,$qua1,$xt1,$x01,$x11,$cm1,$nm1,$pq1) = &split($line1);
    print
    "$id1\t0\t$chr1\t$start1\t$pq1\t$cigar1\t=\t0\t",0, 
    "\t$seq1\t$qua1\tXT:A:$xt1\tCM:i:$cm1\tX0:i:$x01\tX1:i:$x11\tRQ:i:",int($read_qua1),"\tCS:Z:$seq_c1\n";
}

# main function
sub split($){
    $_ = shift;
    chomp;
    my ($aid,undef,undef,undef,undef,undef,$strand,undef,$anno) = split;
# aID, at, b(seq) c(mate type) g(color) o(offset) p() mq(map qua) pq(pair qua)
# r (ref) rb s(next line) u (mismatch) q(qua)
# a (isolate) b (invalid) g(valid) y(double) r(triple) u(misma)
    # split annotation
    if ($anno){
        foreach (@tmp){delete $hash{$_}}; # empty

        my @t = split/;/,$anno;
        foreach (@t){
            if (/(.+) = (.+)/x){
                $hash{$1} = $2;
                #print $1,"\t",$2,"\n"; #M
            }
        }
    }

    # count nucleotide and color mismatch, nm cm
    my ($nm,$cm) = qw(0 0);
    if ($hash{'rb'}){ # count
        $nm = ( $hash{'rb'} =~ s/_/_/isg);
    }
    if ($hash{'r'}){
        $cm = ( $hash{'r'} =~ s/_/_/isg);
    }
    # test field
#    print "$hash{'aID'}\n";
#    print "NM/CM : $nm\t$cm\n";
#    if ($hash{'o'} >= 1) {print "OK\n";}
    #print "STRAND:$strand\n";

    # count x0 x1 xt
    my ($x0,$x1,$xt) = &judge_match_time($hash{'u'},$hash{'rb'});
    
    # seq quality
    $hash{'o'} = 0;
    $hash{'aID'} = $aid;
    $hash{'pq'} = 100;
    my ($seq_c,$qua_n,$seq_n) = 
    &covert_seq_qua($hash{'b'},$hash{'g'},$hash{'o'},$strand,$hash{'q'},$hash{'s'});
    #print "$hash{'b'}\n$hash{'g'}\n$seq_c\n$qua_n\n$seq_n\n";

    #cigar only return nM type , else ignore
    my $cigar = length($hash{'b'})."M";
    return($hash{'aID'},$hash{'c'},$seq_n,$cigar,$seq_c,$qua_n,$xt,$x0,$x1,$cm,$nm,$hash{'pq'});
}


sub judge_match_time($){
    my $seq = shift;
    my @match_time = split/\,/,$seq;
    my ($i,$x1,$x0) = qw(0 0 0);
    my $xt = 'R';
    $x0 = $match_time[0];
    $x1 = $match_time[1] if ($match_time[1]);

    foreach (@match_time){
        if ($_==1) {$xt = 'U';last;}
    }
    return($x0,$x1,$xt);
}

#        TO DO: tag for not only pair-end 
sub tag($$$){ # ignore some case for here all are mate-pair
    my $mate_type = shift;
    my $s1 = shift;
    my $s2 = shift;
    my ($a1,$a2) = qw(0 0);
    my ($tag1,$tag2) = qw(0 0);
    my $pair = 0 ;
    $a1 = 1 if ($s1 eq "-");
    $a2 = 1 if ($s2 eq "-");
    
    if ($mate_type =~ /A.A|B.A/){ #mean mate-pair , insert size OK
        $pair = 2;
    }

     $tag1 = hex( 40 ) + hex( $a1 * 10 ) + hex( $a2 * 20 ) + hex( $pair + 1 );
     $tag2 = hex( 80 ) + hex( $a2 * 10 ) + hex( $a1 * 20 ) + hex( $pair + 1 );
    return($tag1,$tag2);

}

sub covert_seq_qua($$$$$) { # TO DO quality
    my $ns = shift;
    my $cs = shift;
    my $offset = shift;
    my $strand  = shift;
    my $qua = shift;
    my $mismatch = shift;
    my @qua = split /,/,$qua;
    if ($strand eq "-") {
        $ns = reverse ($ns);
        $ns =~ tr/ACGTacgt/TGCAtgca/;
     }

    #---- mismatch and quality
    if ($mismatch){
    my @t = split /,/,$mismatch;
    my @mis_pos;
    foreach (@t) {
        if (/[abyr](\d+)/){ # ignore g - validate , else delete
            push (@mis_pos,$1);
            $qua[$1-1] = 0;
        }
    }
    }

    $qua = qw{};      # covert to ASCII
    for my $i (1..$#qua) {
        if ($qua[$i] > 0 && $qua[$i-1] > 0) {
            if ( $qua[$i] + $qua[$i-1] <= 40 ){
                $qua .= chr(($qua[$i]+$qua[$i-1])+33);
            }
            else {
                $qua .="I";
            }
        }
        else {
            $qua .= "!";
        }
    }
    $qua .= chr($qua[$#qua]+33); 
    #print "QUA: \n$qua\n";


    # quality change, covert cs read, actually ignore this step
    my $cache = substr ($cs,$offset,length($ns)); 
    my $cache_q = substr ($qua,$offset,length($ns));

    if ($offset > 0 && $strand eq "+") {
        $cache =~ s/[0123]//; # remove first
        $cache = substr($ns,0,1).$cache ;
    }

    if ($strand eq "-") {
        $cache =~ s/[ACGTacgt]//i; # remove first
        $cache .= substr($ns,0,1);
#        $cache =~ tr/ACGT/TGCA/;
        $cache = reverse($cache);
        $cache_q = reverse($cache_q);
    }
    
    return($cache,$cache_q,$ns);
}
=head
    my $line2 = <>;
    my ($chr2,undef,undef,$start2,$end2,$read_qua2,$strand2,undef,$anno2) =
    split/\s+/,$line2;
    $chr2 = $chr[$chr2];

#   return($hash{'aID'},$hash{'c'},$seq_n,$cigar,$seq_c,$qua_c,$xt,$x0,$x1,$cm,$nm,$hash{'mq'},$hash{'pq'});
    my
    ($id2,$type2,$seq2,$cigar2,$seq_c2,$qua2,$xt2,$x02,$x12,$cm2,$nm2,$pq2) = &split($line2);
     
    my ($tag1,$tag2) = &tag($type1,$strand1,$strand2);
    my ($mate_chr1,$mate_chr2);
    my ($mate_dis1,$mate_dis2);
    if ($chr1 eq $chr2) {
        $mate_chr1 = $mate_chr2 = "=";
        ($start1 < $start2) ? ($mate_dis1 = $end2 - $start1 +1 ): ($mate_dis1
            = $start2 - $end1 - 1 );
#        $mate_dis1 = $end2 - $start1 ;
        $mate_dis2 = -1 * $mate_dis1;
    }
    else {
        $mate_chr1 = $chr2;
        $mate_chr2 = $chr1;
        $mate_dis1 = $mate_dis2 = 0;
    }
    
    print
    "$id2\t$tag2\t$chr2\t$start2\t$pq2\t$cigar2\t$mate_chr2\t$start1\t",$mate_dis2, 
    "\t$seq2\t$qua2\tXT:A:$xt2\tCM:i:$cm2\tNM:i:$nm2\tX0:i:$x02\tX1:i:$x12\tRQ:i:",int($read_qua2),"\tCS:Z:$seq_c2\n";
=cut
