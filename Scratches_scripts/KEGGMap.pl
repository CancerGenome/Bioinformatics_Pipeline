#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:a.pl  <Input> 
#        DESCRIPTION: input file from txt of http://www.genome.jp/kegg-bin/show_organism?menu_type=pathway_maps&org=hsa
#                     output: KEGG Map ID, KEGG pathway, KEGG Category of pathway, design for human ONLY
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 11 Mar 2016 05:39:55 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

open IN,"$ARGV[0]";
my $header;
print "KEGG_ID\tKEGG_Name\tKEGG_Category\n";
while(my $line =<IN>){
	chomp $line;
	if ($line !~ /^\d/){
		$header = $line;
		$header =~ s/\s+/_/g;
		next;
	}
	else{
		my @line = split/\s+/,$line;
		$line =  shift(@line);
		print $line,"\t",join("_",@line),"\t$header\n";
	}
}
