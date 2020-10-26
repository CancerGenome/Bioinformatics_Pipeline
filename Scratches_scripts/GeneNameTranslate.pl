#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/GeneNameTranslate.pl  -h -g
#        DESCRIPTION: -h : Display this help
#        -g: gene name columns, 
#
#        Given an old gene name, translate to new gene name, may used in burden test result
#        Will not replace if didn't find match, will not replace if gene alias are duplicated
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Sat 11 Apr 2020 11:37:56 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_g);
getopts("hg:");

if(not defined $opt_g){
	$opt_g = 0;
}else{
	$opt_g--;
}

my %alias;
my %count; # avoid duplicate alias to new name;
open IN, "/home/yulywang/db/allid.2017";
while(my $line = <IN>){
	chomp $line;
	my @F = split/\s+/,$line;
	next if($F[19] eq "-");
	my $gene = $F[1];
	my @G = split/\|/,$F[19];
	#print "$F[19]\t$F[1]\n";
	#print join("\n",@G),"\t","$F[1]\n";
	foreach my $g(@G){
		$alias{$g} = $gene;
		$count{$g}++;
	}
}


while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $gene = $F[$opt_g];
	# only replace gene if alias have one to one gene relatioship
	if(exists $alias{$gene}){
		if($count{$gene} == 1){
			#		$F[$opt_g] = 'Change'.$alias{$gene};
			$F[$opt_g] = $alias{$gene};
		}
	}
	print join("\t",@F),"\n";
}



