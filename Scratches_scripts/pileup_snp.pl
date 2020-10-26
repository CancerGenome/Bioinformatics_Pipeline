#!/usr/bin/perl
use warnings;
use strict;

$ARGV[0]|| die "perl $0 <SNP_FILE><STDIN>\n";

sub sub_snp($){  # return pos base depth snp  chr
	my $line = shift;
	chomp $line;
	my @return;
	my @array = split/\s+/,$line;
#	$return[4]= $array[0];
	 $return[2] = $array[3];
	 $return[1] = $array[2];
	 $return[0] = $array[1];
	 $return[3] = ($array[4]=~ s/[agctAGCT]//isg);
	return @return ;
}
=head
my %hash;
open IN, $ARGV[0];
while(<IN>){
	chomp;
	split;
	$hash{$_[0]}{$_[1]} =1;
#print "$_[1]\n";
}
close IN;
#`echo down`;
=cut
while(<STDIN>){
	chomp;
	my @a = sub_snp($_);  # pos base depth snp chr
#---- filter
#next if ($a[1] eq "N"||$a[2] <= 3 || $a[2]>30 || $a[3] eq "") ;
#	if ($hash{$a[4]}{$a[0]}) {print join("\t",@a),"\n" }
		if ($a[3]>0) {print join ("\t",@a),"\n";}
}
