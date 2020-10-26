#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:../bin/strelka_covert.pl  -h -r
#        DESCRIPTION: -h : Display this help
#                     -r : print different header if reverse NT
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 31 Aug 2016 04:43:48 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_r);
getopts("hr");
my %hash=(
	'A'=> 4,
	'C'=> 5,
	'G'=> 6,
	'T'=> 7
);

if($opt_r){
	print "Chr\tPos\tSR.dbsnp\tSR.Status\tSR.tref\tSR.tvar\tSR.tfreq\tSR.nref\tSR.nvar\tSR.nfreq\n";
}
else{
	print "Chr\tPos\tS.dbsnp\tS.Status\tS.tref\tS.tvar\tS.tfreq\tS.nref\tS.nvar\tS.nfreq\n";
}
while(<>){
	next if(/^#/);
	chomp;
	my @F = split/\s+/,$_;
	print "$F[0]\t$F[1]\t-\t$F[6]\t";
	my @N = split/\:/,$F[9]; # A C G T
	my @T = split/\:/,$F[10];
	my (@RefNormal,@RefTumor,@VarNormal,@VarTumor);
	$F[4] = (split/,/,$F[4])[0]; # if multiple genotype, like A, T , chose the first one

	if(exists $hash{$F[3]}){
		@RefNormal = split/,/,$N[$hash{$F[3]}];
		@RefTumor = split/,/,$T[$hash{$F[3]}];
	}
	else{
		@RefNormal = qw{0 0};
		@RefTumor = qw{0 0};
	}

	if(exists $hash{$F[4]}){
		@VarNormal = split/,/,$N[$hash{$F[4]}];
		@VarTumor = split/,/,$T[$hash{$F[4]}];
	}
	else{
		@VarNormal = qw{0 0};
		@VarTumor = qw{0 0};
	}

	if($RefTumor[0]+$VarTumor[0] > 0){
		print $RefTumor[0],"\t",$VarTumor[0],"\t",int($VarTumor[0]/($RefTumor[0]+$VarTumor[0])*1000)/1000,"\t";
	}
	else{
		print "0\t0\t0\t";
	}
	if($RefNormal[0]+$VarNormal[0] > 0){
		print $RefNormal[0],"\t",$VarNormal[0],"\t",int($VarNormal[0]/($RefNormal[0]+$VarNormal[0])*1000 ) / 1000,"\n";
	}
	else {
		print "0\t0\t0\n";
	}

}
