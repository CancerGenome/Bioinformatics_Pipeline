#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#		Unfinished			
#
#        USAGE:  ./sel_sam.pl  
#
#  DESCRIPTION:  Split sam file according chromosome [for too large to sort\]
#		We use criterion as follows:
#		if tag = 77/141/69/133  abandon
#		if tag = 67/131/115/179 at least one uniq reads[follows are same],the other should >=31 total match and less than 5 color mismatchs if local alignment[M].keep,these are good reads for solid
#		if tag = 137/73/153/89  and uniq, keep 
#		if tag = 65/129/113/177 
#			97/145/81/161	
#			99/147/83/163	 one uniq, keep_SV file, these are good for sv detectoin	
#			
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/26/2009 10:03:26 PM
#===============================================================================

		  )
}
use strict;
use warnings;
$ARGV[0]|| &usage();
use FileHandle;
my %handle;
my @name;
for my $i (1..23)
	{
		my $chr="chr".$i;
		push (@name,$chr);
	}
my @other =qw(chrX chrY chrM);
push (@name,@other);
$|= 1;
for my $n (@name){
	my $fh = FileHandle->new("> $n");
	$handle{$n}= $fh;
}
#print Dumper(%handle);
while(<>){
	chomp;
	split;
	if (($_[8]!=0) or  ($_[11] eq "AT:A:U")){
		my $fh = $handle{$_[2]};
		print $fh ($_,"\n");
	}		

}
