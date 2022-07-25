#!/usr/bin/perl
use strict;
use warnings;
if (@ARGV<1)
{die qq(

	perl $0 <file1> <key filed> <file2> <key filed of 1 > <value filed of 2>
	Index from 0 
	a shoule be all value of the filed 2
	Can add multiply line from file2 to file1

)
}
#$ARGV[1]=$ARGV[1]-1;
#$ARGV[3]=$ARGV[3]-1;

open IN,"$ARGV[2]"or die "can not open file\n"; 
my %key_hash;
my $v_2=$ARGV[4];
while(<IN>)
{
	chomp;
	my @info=split;
	if($v_2 ne "a")
	{
#		$ARGV[4]=$ARGV[4]-1;
#my $null = exists $key_hash{$info[$ARGV[3]]} ? ($key_hash{$info[$ARGV[3]]}.=" $info[$ARGV[4]]") : ($key_hash{$info[$ARGV[3]]}=$info[$ARGV[4]])	
		push (@{$key_hash{$info[$ARGV[3]]}},$info[$ARGV[4]]);

	}
	else
	{
#		my $null = exists $key_hash{$info[$ARGV[3]]} ? ($key_hash{$info[$ARGV[3]]}.=" $_") : ($key_hash{$info[$ARGV[3]]}=$_)
		push (@{$key_hash{$info[$ARGV[3]]}},$_);
	}

	#print $info[$ARGV[3]],"\t",$info[$ARGV[4]],"\n";
}
close IN;
open IN ,"$ARGV[0]" or die "can  not open file\n\n";
while(my $line = <IN>)
{
 	chomp $line;
	my @info=split/\s+/,$line;
#	print $key_hash{$info[$ARGV[1]]},"\n";
	if(exists($key_hash{$info[$ARGV[1]]}))
	{	
		foreach my $arr (@{$key_hash{$info[$ARGV[1]]}}){
#	print $line,"\t",$key_hash{$info[$ARGV[1]]},"\n";
			print $line,"\t",$arr,"\n";
		}
	}
	else
	{
		print $line,"\n";	
	}
}
close IN;
