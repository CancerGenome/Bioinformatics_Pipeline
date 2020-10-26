#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:add_dup_name.pl  -h
#        Given a ID name, if they are duplicated, add additional name to it, 
#        for example AD-0054 -> AD-0054_2
#        -c: column index
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 27 Jan 2020 10:40:42 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_c);
getopts("hc:");

if(not defined $opt_c){
	&usage();
}

$opt_c--;

my %hash;

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if(not exists $hash{$F[$opt_c]}){
		$hash{$F[$opt_c]} = 1;
		print join("\t",@F),"\n";
	}elsif(exists $hash{$F[$opt_c]}){
		$hash{$F[$opt_c]}++;
		$F[$opt_c]  = $F[$opt_c]."_".$hash{$F[$opt_c]};
		print join("\t",@F),"\n";
	}
}

