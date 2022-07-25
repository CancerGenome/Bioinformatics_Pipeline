#!/usr/bin/perl 
sub usage(){
	die qq(
#===============================================================================
#
#        USAGE:  ./pop.pl  <F3 file> <R3 file> <Chr_Order>;  F3 head must bigger than R3
#
#  DESCRIPTION:  Statistics depth >= 10 total output total depth
#               
#                 
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  3.1  fix 2.0 bug (rj) fix 3.0 == bug
#      CREATED:  08/14/2009 11:32:21 AM for merge solexa and solid data
#===============================================================================

)
}
use strict;
use warnings;
if ($ARGV[0] eq "-h" or $ARGV[0] eq "-help") {&usage()};
$ARGV[2]|| &usage();

open HASH, $ARGV[2];
my (%hash,%hash_site,%hash_freq);
my %bhash=('C' => 1,'G' => 2,'T' => 3,'A' => 0, 1 => 'C', 2=> 'G', 3=> 'T', 0 => 'A');
my $n=0;
my $count = 0 ;
while(<HASH>){
	chomp;
	$hash{$_} = ++$n;
#	print STDERR "$_\t$hash{$_}\n";
}
open F, $ARGV[0]|| die "Could not open A";
open R, $ARGV[1]|| die "Could not open B";
my ($f, $r);
my (@f, @r);
$r =<R>;
@r = split /\s+/,$r;
$f =<F>;
@f = split /\s+/,$f;
	if ($#f == 17){
		splice(@f,10,1);
	}
while(1){
#	print "$f[0]\t$f[1]\t$hash{$f[0]}\t$r[0]\t$r[1]\t$hash{$r[0]}\t";
#	if ($hash{$f[0]} == $hash{$r[0]}){ #mark
		if($f[1] == $r[1]){
			my @luck = @f[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
			push (@luck,@r[3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
			&judge_print(@luck);
#	&print_f(); 
			&read_r();
			&read_f();
		last unless(defined $r);
		last unless(defined $f);
		}
		elsif ($f[1] >$r[1]){
#print join("\t",@r[0,1,2]),"\t0\t0\t0\t0\t0\t-\t-\t0\t0\t0\t0\t0\t-\t-\t",join("\t",@r[3,4,5,6,7,8,9,10,11,12,13,14,15,16]),"\n"; #mark
			my @luck;
			push(@luck,@r[0,1,2],qw(0 0 0 0 0 - - 0 0 0 0 0 - -),@r[3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
#print join("\t",@luck),"\n";
			&read_r();
			&judge_print(@luck);
		last unless(defined $r);
		}
		elsif ($f[1]< $r[1]){
#			print join("\t",@f[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]),"\t0\t0\t0\t0\t0\t-\t-\t0\t0\t0\t0\t0\t-\t-\n"; #mark
			my @luck;
			push (@luck,@f[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],qw(0 0 0 0 0 - - 0 0 0 0 0 - -)); #mark
#			print join("\t",@luck),"\n";
			&read_f();
			&judge_print(@luck);
		last unless(defined $f);
		}
}

#------ sub
sub print_f(){
#	if (($f[9] ne "-")|| ($r[9] ne "-") || ($r[8] ne $f[8])){ mark
		my @luck = @f[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
		push (@luck,@r[3,4,5,6,7,8,9,10,11,12,13,14,15,16]);
		&judge_print(@luck);
#		print "First sub",join(@luck,"\t"),"\n";
#	}

}
sub print_chr_pos(){
	print $f[0],"\t",$f[1],"\n";
}
sub read_f(){
	$f = <F>;
	chomp $f;
	@f = split /\s+/,$f;
	if ($#f == 17){
		splice(@f,10,1);
	}
}
sub read_r(){
	$r = <R>;
	chomp $r;
	@r = split /\s+/,$r;
}

sub judge_print(@){
	my($chr,$pos,$ref,  # cancer_solexa normal_solexa cancer_solid normal_solid
			$d1,$a1,$c1,$g1,$t1,$f1,$s1,
			$d2,$a2,$c2,$g2,$t2,$f2,$s2,
			$d3,$a3,$c3,$g3,$t3,$f3,$s3,
			$d4,$a4,$c4,$g4,$t4,$f4,$s4,
			)=@_; # a c g t mean ACGT, f means first allele, s means second allele
		my $tag = 1;
=head	
	if (($a1+$a3+$c1+$c3+$g1+$g3+$t1+$t3)<1) {return}
	if (($a2+$a4+$c2+$c4+$g2+$g4+$t2+$t4)<1) {return}
	my @cancer  = (($a1+$a3),($c1+$c3),($g1+$g3),($t1+$t3));
	my @normal  = (($a2+$a4),($c2+$c4),($g2+$g4),($t2+$t4));
#print join("\t",@cancer),"\n";
#print join("\t",@normal),"\n";
	my ($cancer_f,$cancer_s,$cancer_mut)= &get_first_second($ref,@cancer);
	my ($normal_f,$normal_s,$normal_mut)= &get_first_second($ref,@normal);
	if ($cancer_f eq $normal_f and $cancer_f eq $ref and $cancer_s eq "-" and $normal_s eq "-") {return}
	if($tag != 0){print "$chr\t$pos\t$ref\t$cancer_f\t$cancer_s\t$normal_f\t$normal_s\t",join("\t",@cancer),"\t",join("\t",@normal),"\t$cancer_mut\t$normal_mut\n";}

=cut	
my @cache_1=($a1,$c1,$g1,$t1);
my @cache_2=($a2,$c2,$g2,$t2);
my @cache_3=($a3,$c3,$g3,$t3);
my @cache_4=($a4,$c4,$g4,$t4);
my (,,$cache_1) = &get_first_second($ref,@cache);
my (,,$cache_2)= &get_first_second($ref,@cache);
my (,,$cache_3) = &get_first_second($ref,@cache);
my (,,$cache_4) = &get_first_second($ref,@cache);

if(&sum(@cache_1)>=10 and &sum(@cache_3)>=15 and $cache_1 >=1 and $cache_3>=1){print "Cancer\t",&sum(@cache_1),"\t",&sum(@cache_3),"\t",$cache_1,"\t",$cache_3 ,"\t",join("\t",@_),"\n";}
if(&sum(@cache_2)>=10 and &sum(@cache_4)>=15 and $cache_2 >=1 and $cache_4>=1){print "Normal\t",&sum(@cache_2),"\t",&sum(@cache_4),"\t",$cache_2,"\t",$cache_4,"\t",join("\t",@_),"\n";}
}

sub sum(@){
	my @a = @_;
	my $sum;
	foreach (@a){
		$sum += $_;
	}
	$sum = 0.0001  if ($sum==0);
	return($sum);
}

sub get_first_second(@$){
	my $ref = shift;
	my @a = @_;
#print join("\t",@a),"\n";
	my %base;
	my $i = 0;
	my $dep = 0;
	my ($max1,$max2) = @a[0,1];
	my ($rank1,$rank2) = qw(0 1);
	if ($max1 < $max2) {$max1 = $a[1];$max2 = $a[0];($rank1,$rank2)= qw(1 0);}

	foreach my $c(@a) {
		$dep += $c;	
		if ($i >= 2){
			if ($c >= $max1){
				$max2 = $max1;
				$rank2 = $rank1;
				$max1 = $c;
				$rank1 = $i;
			}
			elsif ($c >= $max2){
				$max2 = $c;
				$rank2 = $i;
			}
		}
		$i ++;
	}
#---- return mutant count
	my @re ;
	if ($max2 == $max1 and $bhash{$ref} == $rank2){ $re[0]=$bhash{$rank2};$re[1]=$bhash{$rank1};}
	else {$re[0] = $bhash{$rank1};$re[1]= $bhash{$rank2};}
	if($a[$rank2] == 0 || $a[$rank2]/($dep+0.0001) <0.05){$re[1]="-";}
	if ($bhash{$ref} == $rank2){$re[2] = $a[$rank1];}
	else {$re[2] = $a[$rank2];}
	return(@re);
}
