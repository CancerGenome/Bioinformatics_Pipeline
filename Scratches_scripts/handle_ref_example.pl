#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./sel_sam.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/26/2009 10:03:26 PM
#===============================================================================

		  )
}
use strict;
use warnings;
use Data::Dumper;
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
=head
while(<>){
	chomp;
	split;
	if (($_[8]!=0) or  ($_[11] eq "AT:A:U")){
		my $fh = $handle{$_[2]};
		print $fh ($_,"\n");
	}		
}
=cut

while(<>) {
    chomp;
    split;
    select FileHandle->new("> $_[0]");
    print  $_;
}
