#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@gmail.com>
#
use strict;
use warnings;
require "fet.pl";

$| = 1;

while(my $line = <>){
	chomp $line;
	my @tabs = split /\s/, $line;
	my $matrix = &pairup(&round_all([[$tabs[12] * $tabs[15], $tabs[12] * $tabs[16], $tabs[12] * $tabs[17], $tabs[12] * $tabs[18]],
		[$tabs[20] * $tabs[23], $tabs[20] * $tabs[24], $tabs[20] * $tabs[25], $tabs[20] * $tabs[26]]]));
#	my $pv = fet($matrix);
#print "$line\t$pv\n";
	my $a = $matrix->[0][0]||1;
	my $b = $matrix->[0][1];
	my $c = $matrix->[1][0]||1;
	my $d = $matrix->[1][1];
	my $null = ($b/($a+$b) <=0.05 || $b<=1)? ($b=0): ($b=$b);
	my $null2 = ($d/($c+$d) <=0.05 || $d<=1)? ($d=0): ($d=$d);
#	print "$matrix->[0][0]\t$matrix->[0][1]\t$matrix->[1][0]\t$matrix->[1][1]\n";
	print "$a\t$b\t$c\t$d\n";
}

1;

sub round_all {
	my $matrix = shift;
	for(my $i=0;$i<@$matrix;$i++){
		for(my $j=0;$j<@{$matrix->[$i]};$j++){
			$matrix->[$i][$j] = int(0.5 + $matrix->[$i][$j]);
		}
	}
	return $matrix;
}

sub pairup {
	my $matrix = shift;
	my @data = ();
	for(my $i=0;$i<@$matrix;$i++){
		my $t = 0;
		my $m = 0;
		my $d = 0;
		for(my $j=0;$j<@{$matrix->[$i]};$j++){
			$t += $matrix->[$i][$j];
			if($matrix->[$i][$j] > $m){
				$m = $matrix->[$i][$j];
				$d = $j;
			}
		}
		push(@data, [$d, $m, $t - $m]);
	}
	if($data[0][0] == $data[1][0]){
		return [[$data[0][1], $data[0][2]], [$data[1][1], $data[1][2]]];
	} else {
		return [[$data[0][1], $data[0][2]], [$data[1][2], $data[1][1]]];
	}
}
