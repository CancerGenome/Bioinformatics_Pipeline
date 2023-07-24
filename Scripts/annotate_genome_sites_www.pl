#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./annotate_genome_sites.pl  <Input/- from pipe> <Chr_field:default 1>
#        <Pos_field:default 2>  < Optical: SNP_field:default none>
#
#  DESCRIPTION:  Given annotation (according refseq), 
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/17/2010 
#===============================================================================

)
            }
use strict;
use warnings;

$ARGV[0]|| &usage ;

#my $chr_field = ($ARGV[1]-1) || 0; # field
#my $pos_field = ($ARGV[2]-1) || 1;
my $mut_field = ($ARGV[3]-1) if ($ARGV[3]) ;
my $chr_field =  0; # field
my $pos_field =  1;
#print STDERR $ARGV[3],"\n";
my $current_chr = qw{};
my (@f,@exonStart,@exonEnd,@aa) = qw{};
my (@exonS,@exonE,@txS,@txE,@splice) = qw{}; # for storing judge array
my ($chr_f,$pos_f,$r,$f) = qw{}; # for f
my
($gene,$chr_r,$strand,$txStart,$txEnd,$cdsStart,$cdsEnd,$exonCount,$exonStart,$exonEnd,$seq,$name_id,$start_com,$end_com,$mut)
= qw{};  # for r
my $an = qw{};
# store aa code
while(<DATA>){
    chomp;
    split;
    foreach my $a(@_){
        my @a  = split/\_/,$a;
        push (@aa,$a[1]);
    }
}

&read_f();

while(1){

    if ($chr_f ne $chr_r or $current_chr ne $chr_f) {
        &update_ref();
        &read_r();
    }

    if ($pos_f< $txStart) { # intergenic
        &print_intergenic();
        $an = "INTERGENIC";
        &read_f();
        last unless defined ($f);
    }
    elsif ($pos_f > $txEnd) { # next gene 
        &read_r();
        #    last unless defined ($r);
    }
    elsif ($pos_f <= $txEnd && $pos_f >= $txStart ) { # in this gene

        if ($start_com eq "unk" && $end_com eq "unk") { # cdsStart == cdsEnd
            for my $i (0..$#exonStart){
                if ($pos_f <= $exonEnd[$i] && $pos_f >= $exonStart[$i]) {
                    &print_gene();
                    $an = "ncRNA" ;
                    next;
                }
            }

            print "$f\tINTRON\t$gene\t-\t$name_id\n" if ($an ne 'ncRNA');
            &read_f();
            last unless defined ($f);
        }

        else {
            &judge_detail();
        }


    }
    else {
        &print_intergenic();
        &read_f();
    }

$current_chr = $chr_f;
#print "\n";
}

sub judge_detail(){
    
    for my $i (0..$#exonStart) { # judge UTR or CDS
        if ($pos_f >= $exonStart[$i] and $pos_f <= $exonEnd[$i]) {
            if ($pos_f <= $cdsStart) {
                $an = "UTR";
                print $f,"\tUTR-5\t$gene\t-\t$name_id\n" if ($strand eq "+");
                print $f,"\tUTR-3\t$gene\t-\t$name_id\n" if ($strand eq "-");
            }
            elsif ($pos_f >= $cdsEnd) {
                $an = "UTR";
                print $f,"\tUTR-3\t$gene\t-\t$name_id\n" if ($strand eq "+");
                print $f,"\tUTR-5\t$gene\t-\t$name_id\n" if ($strand eq "-");
            }
            else {
                $an = "CDS";
                print $f,"\tCDS\t$gene\t" if ($an ne "UTR");
            }
        }
    }
    # judge synonymous
#            if ($an eq "CDS" and not defined $ARGV[3]) {
#                print "-\t$name_id\n";
#            }
            if ($an eq "CDS"){
                my $phage = 0 ;
                my $total = 0 ;
                    for my $i (0..$#exonStart) {
                        next if ($exonEnd[$i] < $cdsStart or $exonStart[$i] >
                            $cdsEnd); 
                        my ($s,$e) = ($exonStart[$i],$exonEnd[$i]);
                        $s = $cdsStart if ( $cdsStart > $exonStart[$i] );
                        $e = $cdsEnd if ( $cdsEnd < $exonEnd[$i] ) ;
                        $total += ($e-$s);
                        $e = $pos_f if ($pos_f <= $e && $pos_f >= $s);
                        next if ($pos_f < $s);
                            $phage += ( $e - $s );
                    }
#                    print "\t",$total,"\t$phage\t";
                if ($strand eq "-") { # reverse 
                    $phage = $total - $phage +1;
                    $mut =~ tr/ACGT/TGCA/;
                }

                my $cut = uc(substr($seq,int(($phage-0.1)/3)*3,3));
                my @cut = split//,$cut;
                $cut[$phage%3-1] = $mut; # change mut
#                print "\n",$phage%3,"\n";
#                print "\n$cut[0]\t$cut[1]\t$cut[2]\t\n$cut[($phage%3)-1]\n";
                my $new = join("",@cut);
                my $new_aa = &translate_aa($new);
                my $cut_aa = &translate_aa($cut);
                if ($new_aa eq $cut_aa) {
#                    print "$cut->$new\t$cut_aa->$new_aa\t";
                    print "Syn\t$name_id\n";
                }
                elsif ($new_aa ne $cut_aa) {
                    print "$f\t$cut->$new\t$cut_aa->$new_aa\t$name_id\n";
                }
            }

            if ($an ne "CDS" and $an ne "UTR") {
                print $f,"\tINTRON\t$gene\t-\t$name_id\n";
                $an = "INTRON";
            }
            &read_f();
}

sub translate_aa($){
    my $a = shift;
    $a =~ tr/ACGT/0123/;
#    print "OKKKK\t$a\n";
    my @a = split//,$a;
    return($aa[$a[0] * 16 + $a[1] * 4 + $a[2] * 1 ]);

}

sub update_ref(){
#----- updata file
        if (-e
            "/share/disk7-3/wuzhygroup/wangy/db/anno/hg18_refgene.map_$chr_f"){
            open R,
            "/share/disk7-3/wuzhygroup/wangy/db/anno/hg18_refgene.map_$chr_f";
        }
        else {
            print STDERR "Can not open this chromosome : $chr_f\n";
        }
}

sub read_f(){ # f: query r:database
    $f =<>;
    chomp $f;
    @f = split/\s+/,$f;
    $chr_f = $f[$chr_field]; # query
    $pos_f = $f[$pos_field];
    $mut = uc($f[$mut_field]) if ($mut_field);
}

sub read_r(){
    $r = <R>;
    chomp $r;
    ($gene,$chr_r,$strand,$txStart,$txEnd,$cdsStart,$cdsEnd,$exonCount,$exonStart,$exonEnd,$seq,$name_id,$start_com,$end_com)
    = split/\s+/,$r;# gene chr strand txStart txEnd cdsStart cdsEnd
    @exonStart = split/,/,$exonStart;
    @exonEnd = split/,/,$exonEnd;
    # exonCount exonStart exonEnd Seq uId startStaus endStaus
}

sub print_intergenic(){
    print $f,"\tINTERGENIC\t-\t-\t-\n";
}
sub print_gene(){
    print $f,"\tncRNA\t$gene\t-\t$name_id\n";
}

=head     from read_r
    (@exonS,@exonE,@txS,@txE) = qw{}; # clear,

    for my $i (0..$exonCount-1){
        if ($exonEnd[$i] < $cdsStart or $exonStart[$i] > $cdsEnd) { # outside cds exon
              push ($exonStart[$i],@txS);
              push ($exonEnd[$i],@txE);
              next; # mark
        }
        # abnormal exon 
        my ($s,$e) = ($exonStart[$i],$exonEnd[$i]);
        if ($exonStart[$i] <= $cdsStart ) {
            push ($exonStart[$i] , @txS);
            push ($cdsStart, @txE);
            $s = $cdsStart;
        }
        if ($exonEnd[$i] >= $cdsEnd ){
            push ($cdsEnd,@txS);
            push ($exonEnd[$i],$txE);
            $e = $cdsEnd;
        }
            push ($s,$exonS);
            push ($e,$exonE);
    }
=cut    
__DATA__
AAA_Lys_K   AAC_Asn_N   AAG_Lys_K   AAT_Asn_N
ACA_Thr_T   ACC_Thr_T   ACG_Thr_T   ACT_Thr_T
AGA_Arg_R   AGC_Ser_S   AGG_Arg_R   AGT_Ser_S
ATA_Ile_I   ATC_Ile_I   ATG_Met_M   ATT_Ile_I
CAA_Gln_Q   CAC_His_H   CAG_Gln_Q   CAT_His_H
CCA_Pro_P   CCC_Pro_P   CCG_Pro_P   CCT_Pro_P
CGA_Arg_R   CGC_Arg_R   CGG_Arg_R   CGT_Arg_R
CTA_Leu_L   CTC_Leu_L   CTG_Leu_L   CTT_Leu_L
GAA_Glu_E   GAC_Asp_D   GAG_Glu_E   GAT_Asp_D
GCA_Ala_A   GCC_Ala_A   GCG_Ala_A   GCT_Ala_A
GGA_Gly_G   GGC_Gly_G   GGG_Gly_G   GGT_Gly_G
GTA_Val_V   GTC_Val_V   GTG_Val_V   GTT_Val_V
TAA_Stop_O  TAC_Tyr_Y   TAG_Stop_O  TAT_Tyr_Y
TCA_Ser_S   TCC_Ser_S   TCG_Ser_S   TCT_Ser_S
TGA_Stop_O  TGC_Cys_C   TGG_Trp_W   TGT_Cys_C
TTA_Leu_L   TTC_Phe_F   TTG_Leu_L   TTT_Phe_F
