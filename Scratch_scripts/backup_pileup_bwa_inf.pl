#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./pileup_bwa_inf.pl  <INPUT / - >
#
#  DESCRIPTION:  Get information from bwa pileup file and filter low quality(8) 
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/30/2009 04:51:51 PM
#      Version:  1.0
#===============================================================================

          )
}
use strict;
use warnings;

$ARGV[0] || &usage();

my %base=('C' => 1,'G' => 2,'T' => 3,'A' => 0, 1 => 'C', 2=> 'G', 3=> 'T', 0 => 'A');
my @head_print = qw(#Chr Pos Ref Depth Ave_Qua First Second First_fre Second_fre A C G T Pos_strand Reverse_strand Cons Cons_Qua SNP_Qua Max_map_Q);
    print join("\t",@head_print),"\n";
#    print "$chr\t$pos\t$ref\t",length($new_seq),"\t$ave_qua\t",join ("\t",@c),"\t$cons\t$cons_q\t$snp_q\t$max_map_q\n";
while(<>){
    chomp;
    split; # chr pos ref consen consen_quality snp_quality max_map_quality seq seq_quality
    if ($_[2] eq "*") {
        next;
    }   # omit indel 
    my ($chr,$pos,$ref,$cons,$cons_q,$snp_q,$max_map_q,$dep_old,$seq,$qua) = @_;


#------ remove others
    $seq =~ s/[+-][0-9]+[ACGTNacgtn]+//isg;   # omit indel
    $seq =~ s/(\^\S)|\$//isg;   # omit  ^\S map quality
    if (length($seq) != length($qua)) {
#        print ABNORMAL length($seq),"\t",length($qua),"\t$seq\t$qua\t$_\n";
next;
    }
#    print join("\t",@{$a}),"\t\t$pos\t$dep_old\t$seq\t$qua\t","\n";
#    print length(join("",@{$b})),"\t",$dep_old,"\t",join("",@{$b}),"\t$qua","\n";
    my ($new_seq,$new_qua,$ave_qua)= &filter_quality($seq,$qua);
    next if (not defined $ave_qua );
    $new_seq = join ("",@{$new_seq});
    $new_qua = join ("",@{$new_qua});
#    print "$new_seq\t$new_qua\n";
#my @c = acgt($new_seq);
    my @c = &acgt($new_seq,$ref);
    print "$chr\t$pos\t$ref\t",length($new_seq),"\t$ave_qua\t",join ("\t",@c),"\t$cons\t$cons_q\t$snp_q\t$max_map_q\n";
}

#------- SUB -------

sub filter_quality($$){
    my $a = shift; # seq input
    my $q = shift; # filter 
    my @a = split//,$a;
    my @q = split//,$q;
    my (@new_a,@new_q);
    my $ave_quality;
    for my $i (0..$#a){
        if (ord($q[$i])-33>=0){
        push (@new_a,$a[$i]);
        push (@new_q,$q[$i]);
        $ave_quality += (ord($q[$i])-33);
        }
    }
#if ($ave_quality==0 || $ave_quality eq ""){return 0}
    if (not defined $new_a[0]){return 0}
    else{
        $ave_quality=int($ave_quality/($#new_a+1));
        return(\@new_a,\@new_q,$ave_quality);}
}

sub acgt($$){  # First_base Second_base First_base_allele Second_base_allele A C G T_Count Pos_strand Reverse_strand_Count
    $_ = shift;
    my $dep = length($_);
    my $ref = shift;
    my @b = split//,$_;
    my @a;
    $a[0] = grep /A/i,@b;  # i means ignore A/a
    $a[1] = grep /C/i,@b;
    $a[2] = grep /G/i,@b;
    $a[3] = grep /T/i,@b;
    $a[$base{$ref}] = $dep - $a[0] -$a[1] - $a[2] -$a[3];

    my $i = 0;
    my ($max1,$max2) = @a[0,1]; # record max and sec number
    my ($base1,$base2)= qw(A C);# record base
    if ($max1 < $max2) {$max1 = $a[1];$max2 = $a[0];$base1='C';$base2='A'};

    foreach my $c(@a) {
        if ($i >= 2){
            if ($c >= $max1){
                $max2 = $max1;
                $base2 = $base1;
                $max1 = $c;
                $base1 = $base{$i};
            }
            elsif ($c >= $max2){
                $max2 = $c;
                $base2 = $base{$i};
            }
        }
        $i ++;
    }
    $a[4] = $base1;
    $max2/($dep+0.00001) <0.05  ? ($a[5] = "-") :  ($a[5]=$base2);
    $a[6] = int($max1/($dep+0.000001)*1000+0.5)/1000;
    $a[7] = int($max2/($dep+0.000001)*1000+0.5)/1000;
    $a[8] = grep /A|G|C|T|\./,@b;
    $a[9] = grep /a|g|c|t|\,/,@b;
    return (@a[4,5,6,7,0,1,2,3,8,9]);
}

