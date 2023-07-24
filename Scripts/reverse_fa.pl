#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./reverse.pl  
#
#  DESCRIPTION:  Reverse fasta and translate and out put
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  05/27/2009 10:15:22 AM
#===============================================================================

use strict;
use warnings;
$ARGV[0]|| die "\t\t$0 <input>\n";

sub printfasta($){
my $a =shift;
chomp $a;
my $l=length($a);
#print $l,"\n";
for my $i(0..int($l/60)){
	if ($i<int($l/60)){
	print substr($a,$i*60,60),"\n";
	}
	else {
		print substr($a,$i*60,($l-$i*60)),"\n";
	}
}

}


open IN, $ARGV[0];
my $last = "";
while(<IN>){
	chomp;
	if (/^>/){                             # new chromosome
		if ($last ne ""){
			my $reverse_last =reverse $last;
			$reverse_last =~ tr/AGCTN/TCGAN/;
			printfasta ($reverse_last);
			$last ="";
		}	
	
		print $_,"\n";						# print chr_id
	}

	else {
			$last .= $_;					# paste sequence	
		}	
	if (eof(IN)){							# end of file
			my $reverse_last =reverse $last;
			$reverse_last =~ tr/AGCTN/TCGAN/;
			printfasta ($reverse_last);
	}
	}

