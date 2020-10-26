#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:filter_pathoV1.pl  -h -n
#        DESCRIPTION: -h : Display this help
#        -n: column # before Chrom, by default zero. The line will start with CHROM
#        Combine with call_header3.pl
#        # Redesign to filter utr, intergenic and only keep nonsyn and frameshift and splicing, see details for lof
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
our ($opt_h,$opt_m,$opt_n);
getopts("hmn:");
if(not defined $opt_n){
	$opt_n = 0;
}

my %hash;
my @LOF = qw{frameshift_deletion frameshift_insertion nonframeshift_insertion stopgain stoploss splicing "exonic\x3bsplicing" nonsynonymous_SNV};
foreach my $lof (@LOF){
	$hash{$lof} = 1;
}

my $header = <>;
print $header; 
while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if($F[0] eq "CHROM"){  # header
		print $line,"\tGenotype\n";
		next;
	}

	my $keep_lof = 0 ;
	if(exists $hash{$F[11+$opt_n]}){# annotatin from Annovar refseq
		$keep_lof = 1;
	}elsif(exists $hash{$F[16+$opt_n]}){# annotation from annovar ensemble
		$keep_lof = 1;
	}elsif(exists $hash{$F[8+$opt_n]}){# annotation from annovar refseq splicing
		$keep_lof = 1;
	}elsif(exists $hash{$F[13+$opt_n]}){# annotation from annovar ensemble splicing
		$keep_lof = 1;
	}

	if($keep_lof > 0 ){
		print $line,"\n";
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
