#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./AddGap.pl  -c (compare which columns)
# 
#  DESCRIPTION:  Add gap for with different value
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  07/14/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use Getopt::Std;

our($opt_c);
getopts("c:");
&usage if (!$opt_c);
my @col = split/\,/,$opt_c;
foreach (@col) {
    $_ -- ;
}
#print @col,"\n";

my $line  = <> ;
chomp $line ;
print $line,"\n";
my @F = split/\s+/,$line;
my @last =  @F[@col];
#print @last,"\n";

while(my $line = <>) {
    chomp $line;
	my @F = split/\s+/,$line;
	my @cur = @F[@col];
    for my $i (0..$#col) {
        if ($last[$i] ne $cur[$i]) {
            print "\n";
			#print "_\n";
			#print "Index\tGene\tGene	Ctrl_AC	Case_AC	CHROM	POS	REF	ALT	Ctrl_AC	AF	QD	Func.refGene	Gene.refGene	GeneDetail.refGene	ExonicFunc.refGene	AAChange.refGene	Func.ensGene	Gene.ensGene	GeneDetail.ensGene	ExonicFunc.ensGene	AAChange.ensGene	genomicSuperDups	PopFreqMax	1000G_ALL	ExAC_ALL	ESP6500siv2_ALL	gnomAD_exome_ALL	gnomAD_exome_NFE	gnomAD_genome_ALL	gnomAD_genome_NFE	InterVar_automated	CLNSIG	UMD_Score	UMD_Pred	CADD_raw	CADD_phred	SIFT_score	SIFT_pred	Polyphen2_HVAR_score	Polyphen2_HVAR_pred	CLNALLELEID	CLNDN	CLNDISDB	CLNREVSTAT	Interpro_domain	GTEx_V6p_gene	GTEx_V6p_tissue	snp129	avsnp150	cytoBand	PVS1	PS1	PS2	PS3	PS4	PM1	PM2	PM3	PM4	PM5	PM6	PP1	PP2	PP3	PP4	PP5	BA1	BS1	BS2	BS3	BS4	BP1	BP2	BP3	BP4	BP5	BP6	BP7	DP	FS	MQ	VQSLOD	CHROM	POS	REF	ALT	Case_AC	AD-0025.176082	UMAD-49.121601	UMAD-109.121390	UMAD-115.121461	UMAD-156.121827	UMAD-212.121365	UMAD-225.121617	AD-0228.175530	UMAD-236.121680	UMAD-244.121195	UMAD-272.121658	UMAD-273.121726	AD-0283.175588	UMAD-284.121749	UMAD-292.121615	UMAD-295.121728	UMAD-298.121736	UMAD-302.121376	AD-0312.175539	AD-0320.175543	AD-0322.175560	AD-0326.175531	AD-0332.175538	AD-0333.175582	AD-0334.175527	AD-0335.175521	AD-0338.175518	AD-0339.175532	AD-0353.175575	AD-0366.175528	AD-0370.175586	AD-0374.175550	AD-0375.175576	AD-0402.175535	AD-0421.175540	AD-0424.175542	AD-0432.175526	AD-0443.175581	AD-0446.175558\n";
            last;
        }
    }
    @last = @cur;
    print "$line\n";
}
