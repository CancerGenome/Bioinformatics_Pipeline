#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./get_solid_4.pl  
#
#  DESCRIPTION:  get out solid files which contain 4 mismatch and ,4 mismatch all below 28
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  03/30/2009 05:59:06 PM
#===============================================================================

use strict;
use warnings;
#---- get all mismatch =4 and pos < =28 number
my $total_count =0;
my %hash;
while(<>){
	chomp;
	split;
	next if ($_[5]<4);
		my @array= split /\,/,$_[6];
		my $count =0;
			foreach my $key (@array){
					if ($key =~ /(\d+)_(\d+)/){
						if ($1<=28) {$count ++;}
					}
			}
		if ($count ==4) {$total_count ++; $hash{$_[0]}=1;}
}
print "Total Count of pos <=28 4 mismatch pos is $total_count\n";
my %qua;
open IN, "/share/disk3/solid/data/Indica/Rawdata/BIG_S069_20081213_2_rif_F3_QV.qual";
#open IN, "cache.qv.txt";
while (<IN>) {
	chomp;
	if (/^>/) {
		$_ =~ s/>//;
#print $_,"\n";
		if (exists $hash{$_}) {
			my $sline = <IN>;
			chomp $sline;
			my @array = split /\s+/,$sline;
			foreach (@array){
				my $null = (exists $qua{$_})? ($qua{$_}++) : ($qua{$_}=1);
			}
		}
	}
}

foreach my $key (keys %qua){
	print "$key\t$qua{$key}\n";

}

