#!usr/bin/perl
use strict;
use warnings;
if(@ARGV<1)
{
	print"Usage perl $0 <value of amda>\n";
	exit;
}
my $amda=$ARGV[0];

my $sum=0;
for(my $i=0;$i<=10;$i++)
{   my $fac=1;
	if($i>0)
	{
	  for(my $j=1;$j<=$i;$j++)
	  {$fac=$fac*$j;}
	}
	   #print "$fac\n";
		my $p=($amda**$i*exp((-1)*$amda))/$fac;
		print $i,"\t",$p,"\n";
		$sum+=$p;
}
print "$sum\n";
