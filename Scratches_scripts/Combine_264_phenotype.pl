#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Combine_264_phenotype.pl  -h
#        DESCRIPTION: -h : Display this help
#        Given latest 264 phenotypes, combined them together
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 12 Dec 2019 11:42:49 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

open IN, "/home/yulywang/bin/MY_2019\ V4\ 264\ sample\ for\ COL5A1\ -\ for\ R_191203.csv";
my $header = <IN>;
chomp $header;
my @Header = split/,/,$header;
print $header,",CombinePhenotype\n";

while(my $line = <IN>){
        chomp $line;
        my @F = split/,/,$line;
        $line .= ",";
        my $i = 0;
        for my $i(2..$#F){ # from multifocal.FMD.MY_review to eds
                if($F[$i] ne "-" and $F[$i] !=0){
                        $line  = $line.$Header[$i].";";
                }
        }
		print $line,"\n";
}
