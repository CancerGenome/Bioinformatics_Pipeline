#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Print_IGV.pl  -h
#        DESCRIPTION: -h : Display this help, for trio only
#        Format: Proband, Father, Mother, Chr , Pos 
#        ID should be same with sequencing, will not translate ID here
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Sat 09 Nov 2019 04:56:36 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $pre_proband;
my $pre_father;
my $pre_mother;

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/, $line;
	my $proband = $F[0];
	my $father = $F[1];
	my $mother = $F[2];
	my $chr = "chr".$F[3];
	my $pos = $F[4];
	
	if($pre_proband ne $proband or $pre_father ne $father or $pre_mother ne $mother){
		print "new\n";
		#print "load /tmp/FMD_FLUX_BACKUP_20181023/bam/Sort.Dup.BQ/$proband.sort.dup.bq.bam\n";
		#print "load /tmp/FMD_FLUX_BACKUP_20181023/bam/Sort.Dup.BQ/$father.sort.dup.bq.bam\n";
		#print "load /tmp/FMD_FLUX_BACKUP_20181023/bam/Sort.Dup.BQ/$mother.sort.dup.bq.bam\n";
		#print "snapshotDirectory /tmp/ \n";
		print "load /tmp/FMD_FLUX_BACKUP_20181023/bam/Sort.Dup.BQ/$proband.sort.dup.bq.bam\n";
		print "load /tmp/FMD_FLUX_BACKUP_20181023/bam/Sort.Dup.BQ/$father.sort.dup.bq.bam\n";
		print "load /tmp/FMD_FLUX_BACKUP_20181023/bam/Sort.Dup.BQ/$mother.sort.dup.bq.bam\n";
		print "snapshotDirectory /tmp/ \n";
		print "collapse\n";
	}
	# print for all
		print "goto $chr:$pos-$pos\n";
		print "sort base\n";
		print "sort strand\n";
		print "snapshot $proband\_$chr\_$pos\.png\n";
		$pre_proband = $proband;
		$pre_father = $father;
		$pre_mother = $mother;
}
