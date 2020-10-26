#!/usr/bin/perl -w
#Filename:
#Author:	Du Zhenglin
#EMail:		duzhl@big.ac.cn
#Date:		
#Modified:	
#Description: 
my $version=1.00;

use strict;
use Getopt::Long;


my %opts;
GetOptions(\%opts,"i=s","o=s","h");
if (!(defined $opts{i} and defined $opts{o}) || defined $opts{h}) {			#necessary arguments
	&usage;
}


my $filein=$opts{'i'};
my $fileout=$opts{'o'};

open IN,"<$filein";
open OUT,">$fileout";

my @mismatch;
my @column;
my $focus=10-1;
my $max=10;


for(my $i=0;$i<=$max;$i++){
	$mismatch[$i]=0;	
}

while(my $aline=<IN>){
	chomp($aline);
	@column=split/\s/,$aline;
	$mismatch[$column[$focus]]++;
}

for(my $i=0;$i<=$max;$i++){
	print OUT "$i\t$mismatch[$i]\n";	
}




sub usage{
	print <<"USAGE";
Version $version
Usage:
	$0 -i <input file> -o <output file>
options:
	-i input file
	-o output file
	-h help
USAGE
	exit(1);
}

