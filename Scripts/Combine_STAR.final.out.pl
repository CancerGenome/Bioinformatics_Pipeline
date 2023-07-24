#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/Combine_STAR.final.out.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Given a file list, combine all useful  number together
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 22 Oct 2019 11:18:38 AM EDT
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
my @prefix;

while(my $file = <>){
	chomp $file;
	my $prefix = $file;
	$prefix =~s/Log.final.out//;
	push(@prefix, $prefix);

	open IN, "$file";
	while(my $line = <IN>){
		chomp $line;
		next if $line eq "";
		my @F = split/\|/,$line;
		if($F[0] ne ""){
			$F[0] =~s/^\s+//;
			$F[0] =~s/\s+$//;
			$F[0] =~s/\s+/_/g;
		}
		if(exists $F[1] and $F[1] ne ""){
			$F[1] =~s/^\s+//;
			$F[1] =~s/\s+$//;
			$F[1] =~s/\%//;
			$F[1] =~s/\s+/_/g;
			#print $F[0],"\n",$F[1],"\n";
			$hash{$F[0]}{$prefix} = $F[1];
		}
	}
	close IN;
}

print join("\t",@prefix),"\n";
foreach my $list (keys %hash){
	print "$list";
	foreach my $prefix (@prefix){
		print "\t",$hash{$list}{$prefix};
	}
	print "\n";
}
