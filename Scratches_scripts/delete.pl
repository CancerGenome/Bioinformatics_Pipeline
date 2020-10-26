#!/usr/bin/perl 
#===============================================================================
#         FILE:  delete.pl
#        USAGE:  ./delete.pl  
#  DESCRIPTION:  
#      OPTIONS:  ---
#      AUTHOR:  Jin Xu (), xujin@big.ac.cn
#      COMPANY:  BIG
#      VERSION:  1.0
#      CREATED:  05/04/2009 10:05:57 AM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

if(@ARGV<1)
{
	print "Usage perl $0 <blast.addlen.filter>\n\n";
	exit;
}
open IN , $ARGV[0] or die "can  not open file\n\n";
my %delete;

my %cluster;
while(<IN>)
{
	chomp;
	my @a=split;
    
	if(exists $cluster{$a[0]})
	{
		
		if(!exists $delete{$a[1] })
		{
			push @{$cluster{$a[0]}},$a[1];
			$delete{$a[1]}=1;
		}
	}
	else
	{
		if(!exists $delete{$a[0]})
		 {
			 if(!exists $delete{$a[1]})
			 {
				push @{$cluster{$a[0]}},$a[1];
				$delete{$a[1]}=1;
			 }
		}	
    }		
	
}

my $i=0;

foreach my $key (keys %cluster)
{
	print "cluster_",$i++;
	print "\t", $key;
	my @items=@{$cluster{$key}};
	foreach my $item (@items)
	{print "\t",$item;}
	print "\n";

}
