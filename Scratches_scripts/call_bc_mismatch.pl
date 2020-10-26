#!/usr/bin/perl 
#
#Author: Ruan Jue
#
use warnings;
use strict;

my %corrs = ('A' => 1, 'T' => 1, 'G' => 1, 'C' => 1);

while(<>){
	next if(/^#/);
	my @tabs = split;
	#next unless($tabs[1] eq 'top');
	next unless($tabs[5]);
	my @loci = map {my @ts=split /_/, $_;\@ts} split /,/, $tabs[6];
	push(@loci, undef);
	my $rlen = length($tabs[2]);
	my $last_m;
	foreach my $m (@loci){
		$last_m = &output_mismatch($tabs[0], $tabs[1], $tabs[4], $rlen, $last_m, $m);
	}
}

1;

sub output_mismatch {
	my ($rname, $strand, $rpos, $rlen, $m1, $m2) = @_;
	return $m2 unless($m1);
	$rname =~s/_/\t/g;
	$rpos ++;

	if($m2 and $m1->[0] + 1 == $m2->[0]){
		my $pos = $rpos +(($strand eq 'top')? $m1->[0] : $m2->[0]);
		my $tag = &judge_2colors(substr($m1->[1], 0, 1), substr($m1->[1], 1, 1), substr($m2->[1], 0, 1), substr($m2->[1], 1, 1));
		print qq{$tag\t$pos\t$strand\t$rname\t$m1->[1]\t$m2->[1]\t$m1->[0]\n};
		$m2 = undef;
	} elsif($m1->[0] < $rlen - 1){
		my $pos = $rpos + $m1->[0];
		print qq{E\t$pos\t$strand\t$rname\t$m1->[1]\t$m1->[0]\n};
	}
	return $m2;
}

sub judge_2colors {
	my ($p11, $p12, $p21, $p22) = @_;
	if($corrs{$p11} or $corrs{$p12} or $corrs{$p21} or $corrs{$p22}){
		return "T";
	}
	if($p12 eq $p22){
		return (($p11 eq $p21)? "M" : "C");
	} elsif($p11 ne $p21 and $p11 ne $p12 and $p11 ne $p22 and $p21 ne $p12 and $p21 ne $p22){
		return "M";
	} elsif($p11 eq $p22 and $p21 eq $p12){
		return "M";
	} else{
		return "C";
	}
}
