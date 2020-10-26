#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/FMD.sample.info.pl  -h
#        DESCRIPTION: -h : Display this help
#        Add Unique ID for samples
#        For example: AD-0025 dup -> AD-0025_2
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 13 Feb 2020 05:20:01 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my %hash;

my $line = <>;
chomp $line;
my @F = split/\s+/,$line;
print join("\t",@F),"\t","VCFID\n";

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if(not exists $hash{$F[2]}){
		$hash{$F[2]} = 1;
	}else{
		$hash{$F[2]}++;
	}

	my $new ; 
	if($hash{$F[2]}>1){
		$new = $F[2]."_".$hash{$F[2]};
	}else{
		$new = $F[2];
	}
	
	print join("\t",@F),"\t",$new,"\n";

}
