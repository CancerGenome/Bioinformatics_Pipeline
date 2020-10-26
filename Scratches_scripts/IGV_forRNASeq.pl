#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/IGV.pl  -h -p -d 
#        DESCRIPTION: -h : Display this help
#        Single sample so far, for IGV_trio, please use IGV_Trio.pl
#
#        Input:
#        ID, CHR, POS (sorted by ID)
#        -d: disable translation of ID, AD-0001 ->  UMAD-1.172345, default: will translate 
#
#        -p: prefix of bam file, default: H:\\yulywang\\FMD\\RNASeq\\PedRNA\\Bam; should have \\ for directory
#        -P: surfix of bam file, default: rmdup.bam
#
#        -o: directory of output, default same with bam directory
#        -t: trio file, format: proband parent1 parent2 others...., could be used as multiple sample input
#        Future add: trios
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

my %trio; # record trio samples
if(defined $opt_t){
	open T, "$opt_t";
	while(my $line = <T>){
		chomp $line;
		my @F = split/\s+/,$line;
		$trio{$F[0]} = $line;
	}
}

my $pre_ID = "";
my $pre_Pos = "";
my $proband;
my $chr;
my $pos1;
my $pos2;
my @ID; # record all ID
my $gene;
while(my $line = <>){
	chomp $line;
	#print $line,"\n";
	# -       PRDM16  protein_coding  1:3230537-3230784       21      Neither annotated       2       9:16_C2,12:272_F        -
	my @F = split/\t/,$line;
	my @G = split/,/,$F[7];
	foreach my $g(@G){
		my @H = split/:/,$g;
		push(@ID,$H[1]);
	}
	#print "ID:";
	#print join("\t",@ID),"\n";

	my @P = split/[:-]/,$F[3];
	$gene = $F[1];
	$chr = "chr".$P[0];
	$pos1 = $P[1];
	$pos2 = $P[2];

	$proband = $ID[0]; # first ID
	open OUT, ">$proband\_$gene\_$chr\_$pos1\_$pos2.forIGV";
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
	print "goto $chr:$pos1-$pos2\n";
	print "sort base\n";
	print "sort strand\n";
	print "snapshot $proband\_$gene\_$chr\_$pos1\_$pos2\.png\n";
}

__DATA__
109_A	AD-0109
109_A2	AD-0109
122_A	AD-0122
122_A2	AD-0122
16_C	AD-0016
16_C2	AD-0016
17_B	AD-0017
212_A	AD-0212
212_B	AD-0212
225_B	AD-0225
225_B2	AD-0225
225_C	AD-0225
225_C2	AD-0225
236_A	AD-0236
236_C	AD-0236
236_D	AD-0236
244_C	AD-0244
244_D	AD-0244
25_D	AD-0025
272_E	AD-0272
272_F	AD-0272
272_G	AD-0272
272_H	AD-0272
273_E	AD-0273
273_i	AD-0273
284_A	AD-0284
295_J	AD-0295
295_K	AD-0295
298_G	AD-0298
298_H	AD-0298
298_i	AD-0298
302_D	AD-0302
302_E	AD-0302
312_K	AD-0312
320_C	AD-0320
332_F	AD-0332
333_A	AD-0333
335_B	AD-0335
338_A	AD-0338
339_E	AD-0339
374_C	AD-0374
375_C	AD-0375
406_B	AD-0406
421_H	AD-0421
421_N	AD-0421
424_G	AD-0424
424_M	AD-0424
424_O	AD-0424
432_A	AD-0432
432_F	AD-0432
443_D	AD-0443
486_H	AD-0486
5001_B	ADC-5001
5021_D	ADC-5021
595_F	AD-0595
595_G	AD-0595
614_C	AD-0614
614_D	AD-0614
614_F	AD-0614
625_B	AD-0625
627_B	AD-0627
680_B	AD-0680
680_D	AD-0680
691_A	AD-0691
691_B	AD-0691
691_N	AD-0691
701_D	AD-0701
701_F	AD-0701
701_H	AD-0701
730_C	AD-0730
730_i	AD-0730
759_B	AD-0759
759_O	AD-0759
9001_10Fa	ADC-9001
9001_11F	ADC-9001
9001_12F	ADC-9001
9002_I	ADC-9002
9003_A	ADC-9003
9004_C	ADC-9004
9006_A	ADC-9006
9007_F	ADC-9007
9011_A	ADC-9011
9011_C	ADC-9011
9012_B	ADC-9012
9012_i	ADC-9012
9012_L	ADC-9012
