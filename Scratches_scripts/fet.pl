#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@gmail.com>
#
use warnings;
use strict;

#my $p = &fet([[shift, shift], [shift, shift]]);
#print "$p\n";

1;

sub fac {
	my ($n1, $n2) = @_;
	my $f = 1;
	$n1 = 2 if($n1 < 2);
	for(my $i=$n1;$i<=$n2;$i++){ $f *= $i; }
	return $f;
}

sub fet {
	my $matrix = shift;
	my $a = $matrix->[0][0]||1;
	my $b = $matrix->[0][1];
	my $c = $matrix->[1][0]||1;
	my $d = $matrix->[1][1];
#my $null = ($b/($a+$b) <=0.05 || $b<=1)? ($b=0): ($b=$b);
#	my $null2 = ($d/($c+$d) <=0.05 || $d<=1)? ($d=0): ($d=$d);
	my $r1 = $a + $b;
	my $r2 = $c + $d;
	my $c1 = $a + $c;
	my $c2 = $b + $d;
	my $n = $r1 + $r2;
	my $p = (&fac($a + 1, $r1) * &fac($c + 1, $r2) * &fac($b + 1, $c2)) / (&fac($c1 + 1, $n) * &fac(2, $d));
	$p = int(10000 * $p + 0.5) / 10000;
	return $p;
}
