#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Format_Brown_Result.pl  -h -g 
#        DESCRIPTION: -h : Display this help
#        -g input is grep file as indicated below
#
#        Given the input like this: grep ADAMTSL4 */*brown.method | Format_Brown_Result - > To Fit the excel template
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Wed 28 Aug 2019 11:34:00 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
use List::Util qw( min max );
$ARGV[0] || &usage();
our ($opt_h,$opt_g);
getopts("hg");
# read in database
my %name; 
my %omim;
open IN, "/home/yulywang/db/gene_name";
open IN2, "/home/yulywang/db/omim/omim.gene.txt";
while(my $line = <IN>){
	my @F = split/\s+/,$line;
	$name{$F[0]} = $F[1];
}
close IN;
while(my $line = <IN2>){
	my @F = split/\s+/,$line;
	$omim{$F[3]} = $F[0];
}
close IN2;

while(my $line = <DATA>){
	my @F = split/\s+/,$line;
	print join("\t",@F),"\n";
	$line = <DATA>;
	@F = split/\s+/,$line;
	print join("\t",@F),"\n"; 
}

<>; # skip header

while(my $line = <>){

	chomp $line;
	my $gene; 
	my @F = split/\s+/,$line;
	next if($F[$#F] eq "Inf");
	if(not defined $opt_g){
		$gene = $F[0];
		print "$gene\t";
	}else{
		my @G = split/\:/,$F[0];
		$gene = $G[1];
		my @H = split/\//,$G[0];
		my $cat = $H[0];
		print "$cat\t$gene\t";
	}

	if(exists $omim{$gene}){
		print $omim{$gene},"\t","https://www.omim.org/entry/$omim{$gene}?highlight=$gene\t";
	}else{
		print "-\t-\t";
	}

	if(exists $name{$gene}){
		print $name{$gene},"\t","https://www.genecards.org/cgi-bin/carddisp.pl?gene=$gene\t";
	}else{
		print "-\t-\t";
	}
	print join("\t",@F[1..31]),"\t";
	#print join("\t",@F[32..36]),"\t";
	#print join("\t",@F[4..31]),"\t";
	my @min = grep(!/NA/, @F[4,5,7..10,12..15,17..20,22,23]);
	my $min = min(@min);
	print $min,"\n";

}
#-	-	-	-	-	-	-	-	-	Final_Pvalue_(Brown's_BH_method)	-	-	-	-	LOF_0.01	-	-	-	-	LOF_0.05	-	-	-	-	LOF_Nonsyn_0.01	-	-	-	-	LOF_Nonsyn_0.05	-	-	-	-	Other_Information	-	-	Brown's_Pvalue_before_BH	-	-	-	-	-
__DATA__
-	-	-	-	-	-	-	-	LOF_0.01	-	-	-	-	LOF_0.05	-	-	-	-	LOF_Nonsyn_0.01	-	-	-	-	LOF_Nonsyn_0.05	-	-	-	-	Other_Information	-	-	Brown's_Pvalue	-	-	-	-	-
Gene		OMIM	OMIMLink	Description	GeneCardLink	Chr	Begin	End		Collapse	Madsen	SKAT	VT	WCNT	Collapse	Madsen	SKAT	VT	WCNT	Collapse	Madsen	SKAT	VT	WCNT	Collapse	Madsen	SKAT	VT	WCNT	Variant_Count	Num(P<=1e-3)	MinP	LOF_0.01	LOF_0.05	LOF_Nonsyn_0.01	LOF_Nonsyn_0.05	Min_Brown_P NonSKAT_MinP
