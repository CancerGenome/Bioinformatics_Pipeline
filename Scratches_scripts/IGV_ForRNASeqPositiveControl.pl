#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/IGV.pl  -h -p -P -o
#
#        DESCRIPTION: -h : Display this help
#        Design for RNASeq positive control, only load the relevant bam file, no further action
#        Only load two control samples: ADC5021 as normal renal control, ADC9004 as normal aorta control
#
#        Input format: sample, chr, pos, gene
#        sample format should be: AD-0234, the standard way
#
#        -p: prefix of bam file, default: H:\\yulywang\\FMD\\RNASeq\\PedRNA\\Bam; should have \\ for directory
#        -P: surfix of bam file, default: rmdup.bam
#        -o: directory of output, default same with bam directory
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 13 Dec 2019 10:50:13 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();

our ($opt_h,$opt_d, $opt_p,$opt_P,$opt_o,$opt_t);
getopts("hdp:P:o:t:");

# Default parameters for prefix and surfix and output
if(not defined $opt_p){
	$opt_p = "H:\\yulywang\\FMD\\RNASeq\\PedRNA\\Bam";
}
if(not defined $opt_P){
	$opt_P = "rmdup.bam";
}
if(not defined $opt_o){
	$opt_o = $opt_p;
}

my %hash; # record translated name
while(my $line = <DATA>){
	chomp $line;
	my @F = split/\s+/,$line;
	push( @{$hash{$F[0]}}, $F[1]);
}

my $proband;
my $chr;
my $pos1;
my $gene;
my @ID;

while(my $line = <>){
	chomp $line;
	#print $line,"\n";
	# -       PRDM16  protein_coding  1:3230537-3230784       21      Neither annotated       2       9:16_C2,12:272_F        -
	my @F = split/\t/,$line;

	$proband = $F[0];
	$chr = "chr".$F[1];
	$pos1 = $F[2];
	$gene = $F[3];
	@ID = @{$hash{$proband}};

	open OUT, ">$proband\_$gene\_$chr\_$pos1.forIGV";
	select OUT;
	&print_for_each_new();
	&append_for_each_variant();
	@ID = ();
	close OUT;
}

sub print_for_each_new(){
	# design for each new variants, load data
	print "new\n";
	for my $i (0..$#ID){
		print "load $opt_p\\$ID[$i].$opt_P\n"; # load all bam files
	}
		print "load $opt_p\\5021_D.$opt_P\n"; # 5021 D is the normal renal tissue
		print "load $opt_p\\9004_C.$opt_P\n"; # 9004 C is the normal aorta tissue

	print "snapshotDirectory $opt_o \n";
	print "collapse\n";
}

sub append_for_each_variant(){
	# design for each exising session, only goto specific variant
	print "goto $chr:$pos1\n";
	print "sort base\n";
	print "sort strand\n";
	print "snapshot $proband\_$gene\_$chr\_$pos1\.png\n";
}

__DATA__
AD-0109	109_A
AD-0109	109_A2
AD-0122	122_A
AD-0122	122_A2
AD-0016	16_C
AD-0016	16_C2
AD-0017	17_B
AD-0212	212_A
AD-0212	212_B
AD-0225	225_B
AD-0225	225_B2
AD-0225	225_C
AD-0225	225_C2
AD-0236	236_A
AD-0236	236_C
AD-0236	236_D
AD-0244	244_C
AD-0244	244_D
AD-0025	25_D
AD-0272	272_E
AD-0272	272_F
AD-0272	272_G
AD-0272	272_H
AD-0273	273_E
AD-0273	273_i
AD-0284	284_A
AD-0295	295_J
AD-0295	295_K
AD-0298	298_G
AD-0298	298_H
AD-0298	298_i
AD-0302	302_D
AD-0302	302_E
AD-0312	312_K
AD-0320	320_C
AD-0332	332_F
AD-0333	333_A
AD-0335	335_B
AD-0338	338_A
AD-0339	339_E
AD-0374	374_C
AD-0375	375_C
AD-0406	406_B
AD-0421	421_H
AD-0421	421_N
AD-0424	424_G
AD-0424	424_M
AD-0424	424_O
AD-0432	432_A
AD-0432	432_F
AD-0443	443_D
AD-0486	486_H
ADC-5001	5001_B
ADC-5021	5021_D
AD-0595	595_F
AD-0595	595_G
AD-0614	614_C
AD-0614	614_D
AD-0614	614_F
AD-0625	625_B
AD-0627	627_B
AD-0680	680_B
AD-0680	680_D
AD-0691	691_A
AD-0691	691_B
AD-0691	691_N
AD-0701	701_D
AD-0701	701_F
AD-0701	701_H
AD-0730	730_C
AD-0730	730_i
AD-0759	759_B
AD-0759	759_O
ADC-9001	9001_10Fa
ADC-9001	9001_11F
ADC-9001	9001_12F
ADC-9002	9002_I
ADC-9003	9003_A
ADC-9004	9004_C
ADC-9006	9006_A
ADC-9007	9007_F
ADC-9011	9011_A
ADC-9011	9011_C
ADC-9012	9012_B
ADC-9012	9012_i
ADC-9012	9012_L
