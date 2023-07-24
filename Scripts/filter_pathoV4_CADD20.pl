#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:filter_pathoV1.pl  -h -m(multiple_sample)
#        DESCRIPTION: -h : Display this help
#        Combine with call_header3.pl
#        -m: multiple sample, thus the last column is not required to be het
#
#		A given SNV was designated as “deleterious” in this report if one of the following criteria were met: (1) any 2 of 3
#		ensemble scores predicted a deleterious effect; (2) any 6 of 8 of the following effects were
#		predicted by functional scores: SIFT, deleterious; Polyphen2 HDIV, deleterious or possibly
#		damaging; Polyphen2 HVAR, deleterious or possibly damaging; LRT, deleterious;
#		MutationTaster, deleterious; MutationAssessor, high or medium; FATHMM, deleterious;
#		PROVEAN, deleterious; (3) CADD phred score greater than 20
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 18 Feb 2019 11:03:38 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_m);
getopts("hm");

my %hash;
my @LOF = qw{frameshift_deletion frameshift_insertion nonframeshift_insertion nonframeshift_deletion stopgain stoploss splicing "exonic\x3bsplicing"};
foreach my $lof (@LOF){
	$hash{$lof} = 1;
}

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if($F[0] eq "CHROM"){  # header
		print "#LOF\tClinVar\tEnsemble\tSoftware\tCADD\t",$line,"\tGenotype\n";
		next;
	}

	if(not defined $opt_m){
		if($F[$#F] !~/\/1/ and $F[$#F] !~/\/2/){ # last should be at least het or hom
			next;
		}
	}

	my $keep_lof = 0 ;
	if(exists $hash{$F[11]}){# annotatin from Annovar refseq
		$keep_lof = 1;
	}elsif(exists $hash{$F[16]}){# annotation from annovar ensemble
		$keep_lof = 1;
	}elsif(exists $hash{$F[8]}){# annotation from annovar refseq splicing
		$keep_lof = 1;
	}elsif(exists $hash{$F[13]}){# annotation from annovar ensemble splicing
		$keep_lof = 1;
	}

#	my @LOF = qw{frameshift_deletion frameshift_insertion nonframeshift_insertion stopgain stoploss splicing "exonic\x3bsplicing"};
#	foreach my $lof (@LOF){
#		if($F[11] eq $lof){ # annotatin from Annovar refseq
#			$keep_lof = 1;
#		}
#		if($F[16] eq $lof){ # annotation from annovar ensemble
#			$keep_lof = 1;
#		}
#		if($F[8] eq $lof){ # annotation from annovar refseq splicing
#			$keep_lof = 1;
#		}
#		if($F[13] eq $lof){ # annotation from annovar ensemble splicing
#			$keep_lof = 1;
#		}
#	}

	my $keep_clinvar = 0; # keep this variant;
	if($F[28] =~/Likely_pathogenic|Pathogenic/){
		$keep_clinvar = 1; 
	}

	my $ensemble = 0 ; # record the ensemble prediction
	if($F[80] eq "D"){ #metaSVM only has  D and T
		$ensemble++; 
	}
	if($F[82] eq "D"){ # metaLR only has D and T
		$ensemble++;
	}
	if($F[84] eq "D"){ # M-CAp only has D and T
		$ensemble++;
	}

	my $score_software = 0; # record the software support from eight
	if($F[86] eq "D"){ # SIFT has D
		$score_software++;
	}
	if($F[88] eq "D" or $F[88] eq "P"){ # polyphen2 HDIV
		$score_software++;
	}
	if($F[90] eq "D" or $F[90] eq "P"){ # polyphen2 HVAR
		$score_software++;
	}
	if($F[92] eq "D"){ # LRT has D
		$score_software++;
	}
	if($F[94] eq "A" or $F[94] eq "D"){ # MutationTaster has A: disease causing automatic, D: disease causing
		$score_software++;
	}
	if($F[96] eq "H" or $F[96] eq "M"){ # MutationAssessor has H and M, high and medium
		$score_software++;
	}
	if($F[98] eq "D"){ # FATHMM has D
		$score_software++;
	}
	if($F[100] eq "D"){ # PROVEAN has D
		$score_software++;
	}
	
	my $cadd = 0;

	if($F[102] ne "." and $F[102] >= 20){
		$cadd = 1;
	}

	my $total_software = 0; 
#	if($F[30] ne "."){
#		$total_software++;
#	}
#	if($F[32] ne "."){
#		$total_software++;
#	}
#	if($F[34] ne "."){
#		$total_software++;
#	}
#	if($F[36] ne "."){
#		$total_software++;
#	}

	my $low_freq = 1; 
#	if($F[24] ne "." and $F[26] ne "." and $F[24] >= 0.005 and $F[26] >= 0.005){
#		$low_freq = 0 ;
#	}

	if($keep_lof + $keep_clinvar > 0 or $ensemble >= 2 or $score_software >=6 or $cadd ==1){
# or ($score_software == 1 and $total_software == 1) ){
		print "$keep_lof\t$keep_clinvar\t$ensemble\t$score_software\t$cadd\t",$line,"\n";
	}
}

#5	AC
#6	AF
#7	AN
#8	QD
#9	Func.refGene
#10	Gene.refGene
#11	GeneDetail.refGene
#12	ExonicFunc.refGene
#13	AAChange.refGene
#14	Func.ensGene
#15	Gene.ensGene
#16	GeneDetail.ensGene
#17	ExonicFunc.ensGene
#18	AAChange.ensGene
#19	genomicSuperDups
#20	PopFreqMax
#21	1000G_ALL
#22	ExAC_ALL
#23	ESP6500siv2_ALL
#24	gnomAD_exome_ALL
#25	gnomAD_exome_NFE
#26	gnomAD_genome_ALL
#27	gnomAD_genome_NFE
#28	InterVar_automated
#29	CLNSIG
#30	UMD_Score
#31	UMD_Pred
#32	CADD_raw
#33	CADD_phred
#34	SIFT_score
#35	SIFT_pred
#36	Polyphen2_HVAR_score
#37	Polyphen2_HVAR_pred
#38	CLNALLELEID
#39	CLNDN
#40	CLNDISDB
#41	CLNREVSTAT
#42	Interpro_domain
#43	GTEx_V6p_gene
#44	GTEx_V6p_tissue
#45	snp129
#46	avsnp150
#47	cytoBand
#48	PVS1
#49	PS1
#50	PS2
#51	PS3
#52	PS4
#53	PM1
#54	PM2
#55	PM3
#56	PM4
#57	PM5
#58	PM6
#59	PP1
#60	PP2
#61	PP3
#62	PP4
#63	PP5
#64	BA1
#65	BS1
#66	BS2
#67	BS3
#68	BS4
#69	BP1
#70	BP2
#71	BP3
#72	BP4
#73	BP5
#74	BP6
#75	BP7
#76	DP
#77	FS
#78	MQ
#79	VQSLOD
