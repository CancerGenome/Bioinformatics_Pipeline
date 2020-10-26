#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@gmail.com>
#
use warnings;
use strict;

our @log_cache = ();

1;

sub fet_faction {
	my ($n) = @_;
	if($n < 150){
		my $f = 1;
		for(my $i=2;$i<=$n;$i++){ $f *= $i; }
		return log($f);
	} else {
		my $f = 0;
		for(my $i=2;$i<=$n;$i++){
			$log_cache[$i] = log($i) unless(defined $log_cache[$i]);
			$f += $log_cache[$i];
		}
		return $f;
	}
}

sub fisher_exact_test {
	my $matrix = shift;
	my $x1 = 0;
	my $x2 = 0;
	my $total = 0;
	for(my $i=0;$i<@$matrix;$i++){
		my $r = 0;
		for(my $j=0;$j<@{$matrix->[$i]};$j++){
			$x2 += &fet_faction($matrix->[$i][$j]);
			$r += $matrix->[$i][$j];
		}
		$x1 += &fet_faction($r);
		$total += $r;
	}
	for(my $j=0;$j<@{$matrix->[0]};$j++){
		my $c = 0;
		for(my $i=0;$i<@$matrix;$i++){
			$c += $matrix->[$i][$j];
		}
		$x1 += &fet_faction($c);
	}
	$x2 += &fet_faction($total);
	return exp($x1) / exp($x2);
}
