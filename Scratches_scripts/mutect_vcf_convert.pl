#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:../bin/mutect_vcf_convert.pl  -h -r
#        DESCRIPTION: -h : Display this help
#                     -r : print different header if reverse NT
#        This script is very narrow to mutect vcf, see scripts for more details
#        Will automatic exchange NT based on their genotype, 
#        Output chr pos, rs, status, tumor_ref, tumor_var, tumor_freq, normal_ref, normal_var, normal_freq
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 07 Sep 2016 03:19:38 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_r);
getopts("hr");

#1	158225246	.	C	A	.	PASS	SOMATIC;VT=SNP	GT:AD:BQ:DP:FA:SS	0:44,0:.:44:0.00:0	0/1:21,4:42:25:0.160:2
#1	15688	.	C	T	.	REJECT	.	GT:AD:BQ:DP:FA	0:1,0:.:1:0.00	0/1:0,1:42:1:1.00
#1	17614	rs201057270	G	A	.	REJECT	DB	GT:AD:BQ:DP:FA	0:6,0:.:4:0.00	0/1:2,2:37:4:0.500
# Output chr pos, rs, status, tumor_ref, tumor_var, tumor_freq, normal_ref, normal_var, normal_freq
#

if($opt_r){
	print "Chr\tPos\tMR.dbsnp\tMR.Status\tMR.tref\tMR.tvar\tMR.tfreq\tMR.nref\tMR.nvar\tMR.nfreq\n";
}
else{
	print "Chr\tPos\tM.dbsnp\tM.Status\tM.tref\tM.tvar\tM.tfreq\tM.nref\tM.nvar\tM.nfreq\n";
}
while(<>){
	next if(/^#/);
	chomp;
	my @F = split/\s+/,$_;
	print "$F[0]\t$F[1]\t$F[2]\t$F[6]\t";
	my @T = split/[:,]/,$F[10];
	my @N = split/[:,]/,$F[9];
	if($N[0] eq "0/1"){ # exchange if Normal have frequency
		my @TMP = @T;
		@T = @N;
		@N = @TMP;
	}

	if($F[8] eq "GT:AD:DP:FA"){ # add exceptionanl condition for some mutect result
		print "$T[1]\t$T[2]\t$T[4]\t";
		print "$N[1]\t$N[2]\t$N[4]\n";
	}
	else{
		print "$T[1]\t$T[2]\t$T[5]\t";
		print "$N[1]\t$N[2]\t$N[5]\n";
	}
}
