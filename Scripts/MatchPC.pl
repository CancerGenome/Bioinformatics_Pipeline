#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:MatchPC.pl  -h -p -s -a -g
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        For given sample list, find matched control from known ped file
#        -s: input samples file, this should inlcude both your case and control
#        -p: ped file with age, gender, and PC1 and PC2.
#            default position: ~/db/list/200302\ Burden\ Test\ Pedigree\ PCA\ Files\ \ -\ 040620\ 1158\ ped.tsv
#       -a: age threshold, default 30, if set to 100, means no threshold, step increase 20
#       -g: gender threshold, default 0, if set to anything higher that 1, means nothing
#        Mail: yulywang\@umich.edu
#        Created Time:  Sun 19 Apr 2020 10:24:42 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_s, $opt_p,$opt_a,$opt_g);
getopts("hs:p:a:g:");
if(not defined $opt_a){
	$opt_a = 30;
}
if(not defined $opt_g){
	$opt_g = 0;
}

if(not defined $opt_p){
	#$opt_p="/home/yulywang/db/list/200302\\ Burden\\ Test\\ Pedigree\\ PCA\\ Files\\ \\ -\\ 040630\\ 1158\\ ped.tsv";
	$opt_p="/home/yulywang/db/list/currentped.tsv";
	#print "$opt_p\n";
}

my @sample;
open IN, $opt_s;
while (my $line = <IN>){
    chomp $line;
    my @F = split/\s+/,$line;
	push(@sample, $F[0]);
}
close IN;

my %gender;
my %age;
my %PC1;
my %PC2;
my %used;
open PED, $opt_p;
while (my $line = <PED>){
    chomp $line;
    my @F = split/\s+/,$line;
	#print "$F[0]\n";
	$gender{$F[0]} = $F[4];
	$age{$F[0]} = $F[6];
	$PC1{$F[0]} = $F[8];
	$PC2{$F[0]} = $F[9];
}
my $i = 1 ;
while($i <= 7){
	foreach my $s(@sample){
		next if($s =~/con/); # only focused ped samples
		my $min_dist = 1; 
		my $min_sample = "";

		# find min dist samples and the first try is all samples under 30 years
		my $age_thres = $opt_a;
		my $gender_thres = $opt_g;
		if($i>=5){$gender_thres = 1}; # from 1-4th round, consider gender, then will have fewer male, do not consider gender

		while($min_sample eq ""){
			$age_thres = $age_thres + 20;
			foreach my $s2(@sample){
				next if($s2 !~/con/); # only focused on control samples
				next if(exists $used{$s2} and $used{$s2} == 1);

				$gender{$s} = 0 if ($gender{$s} eq "-");
				$gender{$s2} = 0 if ($gender{$s2} eq "-");
				$age{$s} = 0 if ($age{$s} eq "-");
				$age{$s2} = 0 if ($age{$s2} eq "-");

				if( abs($gender{$s} - $gender{$s2}) <= $gender_thres and abs($age{$s}-$age{$s2}) <= $age_thres){
					my $dist = sqrt(($PC1{$s}-$PC1{$s2})**2 + ($PC2{$s}-$PC2{$s2})**2) ; # eclucdie distance
					$dist = int($dist*10000+0.5)/10000;
					if($dist <= $min_dist){
						$min_dist = $dist;
						$min_sample = $s2;
					}
				}
			}
		} # end searching

		if($min_sample ne ""){
			print "$s\t$min_sample\t$gender{$s}\t$age{$s}\t$PC1{$s}\t$PC2{$s}\t$gender{$min_sample}\t$age{$min_sample}\t$PC1{$min_sample}\t$PC2{$min_sample}\t$min_dist\n";
			$used{$min_sample} = 1;
		} # end print for each sample
	} # end foreach
	$i ++ ; # end foreach
}
