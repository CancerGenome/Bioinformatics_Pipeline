#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yuwang/bin/format_zillow.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Tue 07 Aug 2018 05:55:31 PM DST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $title = 0 ;
while(<>){
	chomp $_;
	if($_ =~/^title/){
		if($title ==0){
			print $_,"\n",
		}
		$title = 1; # do not print next tiem
		next;
	}
	print $_;
	my ($price, $sqft) = qw{"-" "-"};

	if($_ =~/\$(.+?)\"/){
		$price = $1;
		$price =~ s/,//g;
		$price =~ s/\+//g;
		$price =~ s/K/000/g;
		print ",\"",$price,"\"";
	}else{
		print ",\"-\"";
	}

	if($_ =~/ba , (.+?) sqft\"/){
		$sqft = $1;
		$sqft =~ s/,//g;
		$sqft =~ s/\+//g;
		print ",\"",$sqft,"\"";
	}else{
		print ",\"-\"";
	}
	if($price ne "-" and $sqft ne "-" and $sqft ne "--"){
		print ",\"", $price/$sqft,"\"";
	}
	print "\n";
}
