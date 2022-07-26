#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  -h [-] -l
#        DESCRIPTION: -h : Display this help
#        -l: list of gvcf files, defalt: updated ~/db/list/GATK_30samples.list 
#
#        Design for WES ONLY, should have CombineGVCF, GenotypeGVCF
#
#        Have following steps:
#        Step Five: CombineGVCF by each chrosome 30M, input: stepfour, merge 30 samples GVCF 
#        Step Six: GenotypeGVCF on each chromosome 30M
#        Step Seven: Variant Calibration Hard Filter;
#        Step Eight: Annovar annotation 
#      Hard Filter: 
#        SNPs:
#		-filter QD < 5.0 -filter QUAL < 50.0 --cluster-size 3  --cluster-window-size 10
#		-filter SOR > 3.0 -filter FS > 60.0 -filter MQ < 40.0 -filter MQRankSum <-12.5 -filter ReadPosRankSum < -8.0
#	     INDELS:
#		-filter QD < 5.0 -filter QUAL < 50.0 --cluster-size 3  --cluster-window-size 10
#		-filter FS > 60.0 -filter ReadPosRankSum < -20.0
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 07 Jun 2018 02:00:30 PM EDT
#        Note1: update the boundary of 30000001 -> 3000000
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_l);
getopts("hl:");
my $cmd1 = "gatk4.0.5 CombineGVCFs -R /home/yulywang/db/human/hs37d5.fa "; # for CombineGVCF
my $cmd2 = "gatk4.0.5 GenotypeGVCFs -R /home/yulywang/db/human/hs37d5.fa --dbsnp /home/yulywang/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz"; # for genotypeGVCF
if(not defined $opt_l){
	$opt_l = "/home/yulywang/db/list/GATK_CombineGVCF.30samples.list";
}
open LIST, $opt_l;
#
##### Use the 30 samples list, automatically updte 
#
while(my $line = <LIST>){
	chomp $line;
	$cmd1 = $cmd1." -V $line ";
}
close LIST;
chomp ($cmd1);
#########
#

##### Print both GenotypeGVCF and CombineGVCF 
open IN,"/home/yulywang/db/human/hs37d5.fa.fai";
my $i = 0;
while(my $line=<IN>){
	$i++;
	next if($i>25); # only 1-22, X, Y , MT
	chomp $line;
	my @F = split/\s+/,$line;
	my $chr = $F[0];
	my $start = 1; 
	my $end = $F[1];
	my $step = 30000000-1;
	if($end <= $step){
		print "$cmd1 -O ../CombineGVCF/$chr\_$start\_$end.g.vcf.gz -L $chr:$start-$end ; ";
		print "$cmd2 -V ../CombineGVCF/$chr\_$start\_$end.g.vcf.gz -O ../GenotypeGVCF/$chr\_$start\_$end.vcf.gz -L $chr:$start-$end ; ";
		print "GATK_HardFilter_Annovar.sh ../GenotypeGVCF/$chr\_$start\_$end.vcf.gz ../GenotypeGVCF/$chr\_$start\_$end.vcf.gz \n";
		next;
	}
	while($start < $end){
		my $stop = $start + $step;
		$stop = $end if ($end < $stop);
		print "$cmd1 -O ../CombineGVCF/$chr\_$start\_$stop.g.vcf.gz -L $chr:$start-$stop ; ";
		print "$cmd2 -V  ../CombineGVCF/$chr\_$start\_$stop.g.vcf.gz -O ../GenotypeGVCF/$chr\_$start\_$stop.vcf.gz -L $chr:$start-$stop ; ";
		print "GATK_HardFilter_Annovar.sh ../GenotypeGVCF/$chr\_$start\_$stop.vcf.gz ../GenotypeGVCF/$chr\_$start\_$stop.vcf.gz \n";
		$start = $start + $step + 1;
	}
		#print "bcftools mpileup -f /home/yulywang/db/human/hs37d5.fa -b bam.list -r $F[0]:1-$F[1]| bcftools call -mv -Ob -o $F[0]_1_$F[1].bcf\n";
}

# for this batch, wee only use WES 2019 toghter
__DATA__
-V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/24.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/25.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/26.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/27.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/28.vcf.gz -V ~/FMD/SNVCalling_2019/CombineGVCF/30samples/29.vcf.gz -V ../CombineGVCF/30samples/30.vcf.gz -V ../CombineGVCF/30samples/31.vcf.gz -V ../CombineGVCF/30samples/32.vcf.gz -V ../CombineGVCF/30samples/33.vcf.gz -V ../CombineGVCF/30samples/34.vcf.gz -V ../CombineGVCF/30samples/35.vcf.gz -V ../CombineGVCF/30samples/36.vcf.gz -V ../CombineGVCF/30samples/37.vcf.gz -V ../CombineGVCF/30samples/38.vcf.gz -V ../CombineGVCF/30samples/39.vcf.gz -V ../CombineGVCF/30samples/40.vcf.gz
