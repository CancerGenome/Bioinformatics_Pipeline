#!usr/bin/perl
use strict;
use warnings;
#get the head and tail sequence from the scaftig sequences
if (@ARGV<1)
{
print "USage : perl $0 .scaftig scaftigName\n\n";
}


open FA , "$ARGV[0]" or die "can not open file\n\n";




my $scaName=$ARGV[1];

while(my $line=<FA>)
{ 
	if($line =~s/^>//)
	{ 
		chomp ($line);
		my $scan=(split(/\s+/,$line))[0];
		if($scaName eq $scan)
	{	print ">$scaName\n";
		while (<FA>)
		{if($_ =~/^>/){exit 0;}
			else {print $_;}
			}
		
	  }
	
	}
}

	close FA;
