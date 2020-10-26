#!/usr/bin/perl
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  pileupTools  <mpileup INPUT / - > 
#       OPTION:  -s : solexa model <quality perspect>
#                -c : has consenque quality, <-c of pileup is turn on>
#                -f : filter quality \<0\>
#                -m : 1--> chr1 
#                -a : appendix for strand information
#                -p : Output direct pileup result
#
#  DESCRIPTION:  Get information from pileup file and filter low quality
#       OUTPUT:  Chr Pos Ref Depth Ref Non-Ref-First-Base,Non-Ref-Sec-Base,Ref-count,Non-Ref-First-count,Non-Ref-Sec-count, (if option a) Ref_Pos_strand_count, Ref_Neg_strand_count, Non_Ref_First_pos_count, Non_ref_First_neg_count
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/30/2009 04:51:51 PM
#===============================================================================
          )
}

use strict;
#use warnings;
use Getopt::Std;

$ARGV[0] || &usage();
#print @ARGV,"\n";

my %opt= ();
getopts("scf:map",\%opt);
#print "-s $opt{'s'}\n" if defined $opt{'s'};
#print "-c $opt{'c'}\n" if defined $opt{'c'};
#print "-c $opt{f}\n" if defined $opt{f};
#print "\n";

my $cut_quality = $opt{'f'} || 0;
if (defined ($opt{'s'})) {
    $cut_quality += 31; # minor solexa quality is B/2, max is h, 104
}

my %base=('C' => 1,'G' => 2,'T' => 3,'A' => 0, 1 => 'C', 2=> 'G', 3=> 'T', 0
        => 'A',',' => 4, '.' => 4, 'N' => 4 , 4 => '-');
#    my @head_print = qw(#Chr Pos Ref Depth 1st 2nd 1stFre 2ndFre A C G T);
#        print join("\t",@head_print),"\n";

my ($trim_seq,$trim_qua) = qw{};

open IN,$ARGV[0];
while(<IN>){
    chomp;
    next if ($_ eq "") ; 
    my @array = split; # chr pos ref consen consen_quality snp_quality max_map_quality seq seq_quality
    next if ($_[2] eq "*") ; # omit indel 
    my ($chr,$pos,$ref,$seq,$qua);
    if (defined $opt{'c'}) {
        ($chr,$pos,$ref,undef,undef,undef,undef,undef,$seq,$qua) = @array;
    }
    else {
       ($chr,$pos,$ref,undef,$seq,$qua) = @array; 
    }
    if (defined $opt{'m'}) {
        $chr = "chr".$chr;
    }
    $chr =~ s/_validated//g;
    $ref = uc ($ref);
    for my $i(1..int($#array/3)){
#        print $i,"\n";
        my @input;
        push(@input,$chr,$pos,$ref,$array[$i*3],$array[$i*3+1],$array[$i*3+2]);
#        print @input;
#        print "$chr\t$ref\t$array[$i*3+2]\n";
        &call_count_function(@input);
    }
    print "\n" if ( not defined $opt{'p'} );;
}

sub call_count_function(@){
#------ remove others
    my ($chr,$pos,$ref,$dep_old,$seq,$qua) = @_;
    if ( $dep_old == 0 ) {
        print "$chr\t$pos\t$ref\t0\t$ref\t0\t0\t0\t0\t0\t";
        if ($opt{'a'}) {
            print "0\t0\t0\t0\t";
        }
        next;
    }

    my ($tag,$dep,$last_num,$p) = qw(0 0 0 0) ;
    my @count = qw(0 0 0 0 0);
    my %record_strand; # record strand information
    ($trim_seq,$trim_qua) = qw{};

#------ Processing for each line and each character ----------
       for my $i (0..length($seq)-1) {
        my $a = substr($seq,$i,1);
#       print "Sec\t$p\t$a\t$tag\n";
        if ($last_num) {
            if ($a=~/[0-9]/) {
                $tag = $tag * 10 + $a ; # default at last two num
                &pileup($a);
                next;
            }
            else {
                $last_num = 0;
            }
        }

        if ($last_num ==0 and $tag > 0 ) {
            &pileup($a);
            $tag -- ;
            next;
        }
        #print "$last_num\t$tag\t$p\t$a\t$tag\n";

        if ($a eq '^' ) {
            &pileup($a);
            $tag = 1;
        }
        elsif ($a eq '$' or $a eq '+' or $a eq '-') {
            &pileup($a);
        }

        elsif ($a =~ /[0-9]/) {
                &pileup($a);
                $tag = $a;
                $last_num = 1 ;
        }
        elsif ($a eq "*") {
            &pileup($a);
            &pileup_qua(substr ($qua,$p,1));
            $p ++;
        }
        else {
            #print STDERR $p,"$a\t$tag\n";
            if (ord( substr ($qua,$p,1)) -33  >= $cut_quality ) {
                #    print STDERR ord(substr ($qua,$p,1))-33,"\n";
                $count[$base{uc($a)}] ++ ;  # record in array, can be located and sorted via its array position
                $record_strand{$a} ++ ;
#                print $a,"\n";
                $dep ++ ;
                #print "First\t$a\n";
                &pileup($a);
                &pileup_qua(substr ($qua,$p,1));
            }
            $p ++;
        }
    }
        $count[$base{uc ( $ref ) }] += $count[4];
        pop @count;
        my @idx = sort {$count[$b] <=> $count[$a]} grep {$_ != $base{$ref} } qw(0 1 2 3);
        push(@count,0);
            for my $i (0..$#idx)  {
              if ($count[$idx[$i]] == 0) {
                $idx[$i] = 4;
               }
            }
        print "$chr\t$pos\t$ref\t$dep\t$trim_seq\t$trim_qua\n" if($opt{'p'} && $dep);
        next if ($opt{'p'}); # omit next if print pileup format

        if ($dep) {
        print
        "$chr\t$pos\t$ref\t$dep\t$ref\t$base{$idx[0]}\t$base{$idx[1]}\t$count[$base{$ref}]\t$count[$idx[0]]\t$count[$idx[1]]\t";

                if ($opt{'a'}) {
                    my @a;
                    push(@a,'.',',',uc($base{$idx[0]}),lc($base{$idx[0]}),'-');
                    foreach  my $a (@a) {
                        # print "Now base$a\n";
                        #print "Exists\t$a\n" if($record_strand{$a});
                        $record_strand{$a} = 0  if (!$record_strand{$a});
                    }
                        print "$record_strand{'.'}\t$record_strand{','}\t$record_strand{uc($base{$idx[0]})}\t$record_strand{lc($base{$idx[0]})}\t";
                }
        }
        else {
            print "$chr\t$pos\t$ref\t0\t$ref\t0\t0\t0\t0\t0\t";
            if ($opt{'a'}) {
                print "0\t0\t0\t0\t";
            }
        }
}

sub pileup($){
     my $a = shift;
     $trim_seq .= $a;
}
sub pileup_qua($){
     my $a = shift;
     $trim_qua .= $a;
}


=head
        my ($fir,$sec,$thr,$firA,$secA,$thrA) = qw{- - - 0 0 0};
        my ($firC,$secC,$thrC)=qw{0 0 0};
        if ($dep) {
            $fir = $base{$rank[0]};
            $firA = int($count[$rank[0]]/($dep+0.000001)*1000+0.5)/1000;
            $firC = $count[$rank[0]];
            if ($count[$rank[1]] > 0){
                $sec = $base{$rank[1]};
                $secA = int($count[$rank[1]]/($dep+0.000001)*1000+0.5)/1000;
                $secC = $count[$rank[1]];
            }
            if ($count[$rank[2]] > 0){
                $thr = $base{$rank[2]};
                $thrA = int($count[$rank[2]]/($dep+0.000001)*1000+0.5)/1000;
                $thrC = $count[$rank[2]];
            }

            if ($fir ne $ref and $count[$base{$ref} ] == $count[$base{$fir} ]) {
                print
                "$chr\t$pos\t$ref\t$dep\t$ref\t$fir\t$firA\t$firA\t",join("\t",@count),"\n";
            }
            else {
                print
                "$chr\t$pos\t$ref\t$dep\t$fir\t$sec\t$firA\t$secA\t",join("\t",@count),"\n";
            }

            if ($fir eq $ref){
                print
                "$chr\t$pos\t$ref\t$dep\t$ref\t$sec\t$thr\t$firC\t$secC\t$thrC\n";
            }
            elsif ($sec eq $ref){
                print
                "$chr\t$pos\t$ref\t$dep\t$ref\t$fir\t$thr\t$secC\t$firC\t$thrC\n";
            }
            elsif ($thr eq $ref){
                print
                "$chr\t$pos\t$ref\t$dep\t$ref\t$fir\t$sec\t$thrC\t$firC\t$secC\n";
            }
            else {
                print
                "$chr\t$pos\t$ref\t$dep\t$ref\t$fir\t$sec\t0\t$firC\t$secC\n";
            }

        }
=cut
