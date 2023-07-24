#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV<3)
{
	print "Usage : perl $0 <ref.fa> <query.fa><blat.out>\n\n";
	exit;
}

open REF,"$ARGV[0]"or die "can not open file $ARGV[0]\n\n";
open Q,"$ARGV[1]" or die "can not open file $ARGV[1]\n\n";
open BO,"$ARGV[2]" or die "can not open file $ARGV[2]\n\n";
my %seq_ref;
my $name_ref;
while (my $line=<REF>)
{
	chomp($line);
	 if($line=~s/^>//)
	{
		$name_ref=(split(/\s+/,$line))[0];
	#	print $name_ref,"\n";
	}
	else
	{$seq_ref{$name_ref}.=$line;}
}

my %seq_q;
my $name_q;
while (my $line=<Q>)
{
	chomp($line);
	 if($line=~s/^>//)
	{
		$name_q=(split(/\s+/,$line))[0];

	}
	else
	{$seq_q{$name_q}.=$line;}
}

while (my $line=<BO>)
{
	chomp($line);
	my @info=split(/\s+/,$line);
	my $qname=$info[0];
	my $refname=$info[1];
#	print $qname,"\t",$refname,"\n";
	my $q_l=length($seq_q{$qname});
	my $ref_l=length($seq_ref{$refname});
	
	print $line,"\t",$q_l,"\t",$ref_l,"\n";
	
}
