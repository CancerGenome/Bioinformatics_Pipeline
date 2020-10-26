#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/Split_Pos.pl  -h
#        DESCRIPTION: -h : Display this help
#        This is the reverse process of Collapse_Pos, given a file collapsed, will split them into different rows,
#        Add clinical phenotypes here in the last line (191212)
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 29 Aug 2019 09:29:29 AM EDT
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
open IN, "/home/yulywang/bin/FMD.all.sample.info";

my $header = <IN>;
$hash{'header'}  = $header;
my @Header = split/\s+/,$header;

while(my $line = <IN>){
	chomp $line;
	my @F = split/\s+/,$line;
	$line .= "\t";
	my $i = 0; 
	for my $i(10..62){ # from multifocal.FMD.MY_review to eds
		if($F[$i] ne "-" and $F[$i] !=0){
			$line  = $line.$Header[$i].";";
		}
	} 
	$hash{$F[1]}  = $line;
}

my $line = <>;
chomp $line;
print "Sample\t$line\t$hash{'header'}";

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;	
	my @G = split/;/,$F[0];
	foreach my $g(@G) {
		#print "GG\t$g\n";
		my @H = split/\(/,$g;
		if(exists $hash{$H[0]}){
			print $H[0],"\t",$line,"\t",$hash{$H[0]},"\n";
		}else{
			print $H[0],"\t",$line,"\t-"x63,"\n";
		}
	}
}
