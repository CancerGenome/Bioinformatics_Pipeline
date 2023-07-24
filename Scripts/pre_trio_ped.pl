#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:pre_trio_ped.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Sun 10 May 2020 10:02:11 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");
my %bamid;
my %vcfid;
my %gender;
my %age;

open IN,"/home/yulywang/bin/FMD.sample.info";
while(my $line = <IN>){
	chomp $line;
	my @F = split/\s+/,$line; # 0,sample,1 role, 2 shortID,3 gender,4 age,5 IBD,6 bamid,7 vcfid,8 batch
	$bamid{$F[7]} = $F[6]; # trans bam id to vcf id
	$vcfid{$F[6]} = $F[7]; # trans vcf id to bam id
	if($F[3] eq "M"){
		$F[3] = 1;
	}elsif($F[3] eq "F"){
		$F[3] = 2;
	}
	$gender{$F[6]} = $F[3]; # record gender with bam id
	$age{$F[6]} = $F[4]; # record age with bam id
}
while(my $line = <DATA>){
	chomp $line;
	my @F = split/\s+/,$line; # bam id for proband, bam id for parent1 and 2.
	my $vcf = $vcfid{$F[0]};
	my $gender = $gender{$F[0]};
	my $fa_id;
	my $mo_id;
	if($gender{$F[1]} == 1){ # father
		$fa_id = $vcfid{$F[1]};
		$mo_id = $vcfid{$F[2]};
	}elsif($gender{$F[1]} == 2){ # mother
		$fa_id = $vcfid{$F[2]};
		$mo_id = $vcfid{$F[1]};
	}
	print "$vcf\t$fa_id\t0\t0\t1\n";
	print "$vcf\t$mo_id\t0\t0\t2\n";
	print "$vcf\t$vcf\t$fa_id\t$mo_id\t$gender\n";
}


### ID below are BAM ID, need to translate to VCF IF.
__DATA__
ProbandID FatherID MotherID
