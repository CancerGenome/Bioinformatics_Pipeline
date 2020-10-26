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
GetOptions(\%opts,"i=s","l:s","o=s","h");
if (!(defined $opts{i} and defined $opts{o}) || defined $opts{h}) {			#necessary arguments
	&usage;
}


my $filein=$opts{'i'};
my $fileout=$opts{'o'};
my $snpfile=$opts{l};

my @column;
my %snp;

my @reads_base;
my @reads_qv;
my @reads_position;

my @stat_reads_position;
my @stat_reads_qv;
for(my $i=0;$i<=40;$i++){
	$stat_reads_qv[$i]=0;
	$stat_reads_position[$i]=0;
}

my $gene_id;
my $position;
my $ref_base;
my $primary_base;
my $secondary_base;

my $count_base;


open SNP,"<$snpfile";
while(my $aline=<SNP>){
	next if($aline=~/^#/);
	@column=split/\t/,$aline;
	$gene_id=$column[0];
	$position=$column[1];
	$ref_base=$column[2];
	$primary_base=$column[4];
	$primary_base=substr($primary_base,0,1);
	$secondary_base=$column[5];
	$secondary_base=substr($secondary_base,0,1);
	
	if($primary_base ne $ref_base){
		$snp{$gene_id."-".$position}=$primary_base;
	}else{
		$snp{$gene_id."-".$position}=$secondary_base;
	}
}

open IN,"<$filein";
while(my $aline=<IN>){
	chomp($aline);
	@column=split/\t/,$aline;
	$gene_id=$column[0];
	$position=$column[1];
	$ref_base=$column[2];
	
	if(defined $snp{$gene_id."-".$position}){
		$count_base=$snp{$gene_id."-".$position};
		@reads_base=split//,$column[4];
		@reads_qv=split//,$column[5];
		@reads_position=split/,/,$column[7];
		
		for(my $i=1;$i<=$#reads_base;$i++){
			if(uc($reads_base[$i]) eq $count_base){
				$stat_reads_qv[ord($reads_qv[$i])-33]++;
				$stat_reads_position[$reads_position[$i-1]]++;
			}
		}
	}
}

open OUT,">$fileout";
print OUT "Statistics for reads postion:\n";
for(my $i=0;$i<=$#stat_reads_position;$i++){
	print OUT "$i\t$stat_reads_position[$i]\n";
}
print OUT "Statistics for base qv:\n";
for(my $i=0;$i<=$#stat_reads_position;$i++){
	print OUT "$i\t$stat_reads_qv[$i]\n";
}



sub usage{
	print <<"USAGE";
Version $version
Usage:
	$0 -i <input file> -o <output file>
options:
	-i input pileup file
	-l input snp list file
	-o output file
	-h help
USAGE
	exit(1);
}

