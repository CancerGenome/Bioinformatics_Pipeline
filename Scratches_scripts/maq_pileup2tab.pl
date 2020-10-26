#!/usr/bin/perl -w
#Filename:
#Author:	Du Zhenglin
#EMail:		duzhl@big.ac.cn
#Date:		
#Modified:	
#Description: 
my $version=1.00;

use strict;
use Getopt::Long;


my %opts;
GetOptions(\%opts,"i=s","o=s","h");
if (!(defined $opts{i} and defined $opts{o}) || defined $opts{h}) {			#necessary arguments
	&usage;
}
#print "i:$opts{i} o:$opts{o}\n";

my $filein=$opts{'i'};
my $fileout=$opts{'o'};

open IN,"<$filein";
open OUT,">$fileout";

my @info;
my %base_count;
my $ref_count;

while(<IN>){
	chomp;
	@info=split(/\t/);
	$base_count{A}=$info[4]=~tr/[Aa]//;
	$base_count{C}=$info[4]=~tr/[Cc]//;
	$base_count{T}=$info[4]=~tr/[Tt]//;
	$base_count{G}=$info[4]=~tr/[Gg]//;
	$ref_count=$info[4]=~tr/[,\.]//;
	$base_count{$info[2]}=$ref_count;
	

	print OUT "$info[0]\t$info[1]\t$info[3]\t$info[2]\t";
	
	print OUT "$base_count{A}\t";
	print OUT "$base_count{C}\t";
	print OUT "$base_count{T}\t";
	print OUT "$base_count{G}\t";

	unless($info[3]){
		print OUT "\n";
		next
	};
	print OUT digits($base_count{A}/$info[3],5)."\t";
	print OUT digits($base_count{C}/$info[3],5)."\t";
	print OUT digits($base_count{T}/$info[3],5)."\t";
	print OUT digits($base_count{G}/$info[3],5)."\t";

	print OUT "\n";
}


#decimal digits
sub digits{
	my ($decimal,$digits_num)=@_;
	$decimal=int($decimal*10**($digits_num)+0.5)/10**($digits_num);
	return $decimal;
}

sub usage{
	print <<"USAGE";
Version $version
Usage:
	$0 -i <input file> -o <output file>
options:
	-i input maq tileup file
	-o output file
	-h help
USAGE
	exit(1);
}

