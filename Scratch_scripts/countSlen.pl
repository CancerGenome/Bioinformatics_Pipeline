#!usr/bin/perl
use strict;
use warnings;
if (@ARGV<1)
{
print "USage : perl $0   sequence.fa   \n\n";
exit 0;
}


open FA,"$ARGV[0]" or die "can not open file $ARGV[0]\n\n";
open OUT ,">$ARGV[0].length" or die "can not write file \n\n";
my %seqs;

my $scaName;
while(my $line=<FA>)
{chomp($line); 
	if($line =~s/^>//)
	{ 
		
		$scaName=(split(/\s+/,$line))[0];
	#	print "$scaName\n";
		$seqs{$scaName}="";
	  }
	  	
	else
	{
		my $seq=$line;
  		
		$seqs{$scaName}.=$seq;
	         #print "$seq";
	 }
	}
	
	foreach my $key( keys %seqs)
	{
	  print OUT $key,"\t";
	  print OUT length($seqs{$key}),"\n";
	}
