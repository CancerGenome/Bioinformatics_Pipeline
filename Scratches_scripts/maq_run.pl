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
use File::Basename;

my %opts;
GetOptions(\%opts,"r=s","v:s","f:s","b:s","o=s","h");
if (!(defined $opts{o}) || defined $opts{h}) {			#necessary arguments
	&usage;
}


my $filein=$opts{'i'};
my $output_dir=$opts{'o'};
unless($output_dir=~/\/$/){
	$output_dir.="/";
}

my $maq_path="/bioinform/pub/maq-0.7.1/maq";
my $ref_valid_script_path="/bioinform/duzhl/bin/validate_sequence.pl";

my $reference_raw;
my $reference_valid;
my $reference_bfa;

my $mismatch=3;

my $reads_fastq_file;
my $reads_fqstd_file;
my $reads_bfq_file;

my $base_filename;
my $file_path;

my $map_file;
my $mapview_file;
my $pileup_file;



if(defined $opts{r}){			#if validate reference file
	$base_filename=file_cutext($reference_raw);
	$reference_valid="$output_dir$base_filename.check";
	$reference_bfa="$output_dir$base_filename.bfa";
	
	system("$ref_valid_script_path -i $reference_raw -o $reference_valid");
	system("$maq_path fasta2bfa $reference_valid $reference_bfa");
}
if(defined $opts{v}){
	$reference_bfa=$opts{v};
}


if(defined $opts{b}){			#if convert fastq reads to bfq
	$reads_bfq_file=$opts{b};
	$base_filename=file_cutext($reads_bfq_file);
}
if(defined $opts{f}){
	$reads_fastq_file=$opts{f};
	$base_filename=file_cutext($reads_fastq_file);
	$reads_fqstd_file="$output_dir$base_filename.std";
	$reads_bfq_file="$output_dir$base_filename.bfq";
	
	system("$maq_path sol2sanger $reads_fastq_file $reads_fqstd_file");
	system("$maq_path fastq2bfq $reads_fqstd_file $reads_bfq_file");	#gz?
}
$map_file="$output_dir$base_filename.map";
$mapview_file="$output_dir$base_filename.map.txt";
$pileup_file="$output_dir$base_filename.pileup";


system("$maq_path map -n $mismatch $map_file $reference_bfa $reads_bfq_file");
system("$maq_path mapview $map_file > $mapview_file");
system("$maq_path pileup -v -P $reference_bfa $map_file > $pileup_file");

##########################
sub file_cutext{		#must use File::Basename; e.g. /data/test.check.fa -> test.check
	my ($filename)=@_;
	my $base_filename=basename($filename);
	if($base_filename=~/^(\S+)\./){
		return $1;
	}else{
		return $base_filename;
	}
}


sub usage{
	print <<"USAGE";
Version $version
Usage:
	$0 
options:
	-r reference file
	-v reference bfa file
	-f reads fastq file
	-b reads bfq file
	-o output file
	-h help
USAGE
	exit(1);
}

