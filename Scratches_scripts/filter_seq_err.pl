#!/usr/bin/perl -w
#
#Author: Ruan Jue
#
use strict;
use warnings;

while(<>){
	my @tabs = split;
	next unless(@tabs >= 27);
	my $normal = &call_SNV($tabs[12], @tabs[15..18]);
	my $recur  = &call_SNV($tabs[20], @tabs[23..26]);
	unless($normal->[0] == $recur->[0] and $normal->[1] == -1 and $recur->[1] == -1){
		print join("\t", @tabs), "\n";
	}
}

1;

sub call_SNV {
	my ($depth, @acgt) = @_;
	my $major = [-1, 0];
	my $minor = [-1, 0];
	for(my $i=0;$i<@acgt;$i++){
		if($acgt[$i] > $major->[1]){
			$minor->[0] = $major->[0];
			$minor->[1] = $major->[1];
			$major->[0] = $i;
			$major->[1] = $acgt[$i];
		} elsif($acgt[$i] > $minor->[1]){
			$minor->[0] = $i;
			$minor->[1] = $acgt[$i];
		}
	}
	$minor->[0] = -1 if($depth * $minor->[1] <= 1 or $minor->[1] < 0.05);
	return [$major->[0], $minor->[0]];
}
