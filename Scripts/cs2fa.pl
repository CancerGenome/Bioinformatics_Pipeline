#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./cs2fa.pl  
#
#  DESCRIPTION:  Trans color space to sequence
#				 Reverse output reverse seq			
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/28/2009 
#===============================================================================

		  )
}
use strict;
use warnings;

$ARGV[0]||&usage();

my %trans;

$trans{'A'}{'0'}= 'A';
$trans{'C'}{'0'}= 'C';
$trans{'G'}{'0'}= 'G';
$trans{'T'}{'0'}= 'T';

$trans{'A'}{'1'}= 'C';
$trans{'A'}{'2'}= 'G';
$trans{'A'}{'3'}= 'T';

$trans{'C'}{'1'}= 'A';
$trans{'C'}{'3'}= 'G';
$trans{'C'}{'2'}= 'T';

$trans{'G'}{'2'}= 'A';
$trans{'G'}{'3'}= 'C';
$trans{'G'}{'1'}= 'T';

$trans{'T'}{'3'}= 'A';
$trans{'T'}{'2'}= 'C';
$trans{'T'}{'1'}= 'G';

	my $line = $ARGV[0];
	chomp $line;
	my @a  = split //,$line;
	print "Color\t$line\nNow\t";
	if ($line =~/^([AGCTagct])/){
		my $last = $1;
		shift @a;
		foreach my $a (@a){
			$last = $trans{$last}{$a};
			print "$last";
		}	
	}
	elsif ($line =~/([AGCTagct])$/){
		my $last = $1;
		$last=~tr/ACGT/TGCA/;
		my $reverse = reverse $line;
		@a  = split //,$reverse;
		shift @a; # revmoe last one
		foreach my $a (@a){
			$last = $trans{$last}{$a};
			print "$last";
		}	
	}

print "\n";
