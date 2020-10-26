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
AD-0115.175566	AD-0114.175541	AD-0113.175571
AD-0322.175560	AD-0380.175553	AD-0381.175525
AD-0424.175542	AD-0426.175589	AD-0425.175533
AD-0025.176082	AD-0028.175537	AD-0029.175585
AD-0049.175579	AD-0388.175534	AD-0050.175563
AD-0109.175587	AD-0111.175551	AD-0110.175570
AD-0283.175588	AD-0286.175583	AD-0285.175549
AD-0295.175573	AD-0297.175580	AD-0296.175568
AD-0312.175539	AD-0309.175555	AD-0310.175561
AD-0320.175543	AD-0323.175562	AD-0321.175557
AD-0326.175531	AD-0327.175548	AD-0328.175572
AD-0374.175550	AD-0438.175523	AD-0439.176083
AD-0421.175540	AD-0423.175536	AD-0422.175517
AD-0432.175526	AD-0434.175545	AD-0433.175577
AD-0443.175581	AD-0445.175569	AD-0444.175552
AD-0446.175558	AD-0447.175564	AD-0448.175578
AD171	AD172	AD173
AD115	AD113	AD114
AD283	AD285	AD286
AD284	AD287	AD289
AD295	AD296	AD297
AD312	AD309	AD310
AD370	AD441	AD475
AD486	AD487	AD488
AD489	AD492	AD493
AD498	AD499	AD500
AD451	AD449	AD452
AD547	AD545	AD546
AD555	AD556	AD557
AD578	AD579	AD580
AD691	AD692	AD693
AD759	AD760	AD761
AD742	AD748	AD768
