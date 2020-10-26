#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./call_anno_error.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  07/13/2009 07:04:05 PM
#===============================================================================

use strict;
#use warnings;
$ARGV[0]||die qq(
		
		Call_anno_error.pl <Input>  input file is corona gff.annotate file
		Print each position error type, pos, strand, tag, error detail


);


	my %hash=('a' => 1,'g' => 2,'y' => 3,'r' => 4,'b' => 2);
	my %num=('a' => 1,'g' => 1,'y' => 2,'r' => 3,'b' => 1);
while(<>){
	chomp;
	next if (/^#/);
	split; # 0ID 3start 4end 6strand 8frame
	if ($_[8]=~/(s=.*;)/){
#	if (my @array=m/([agryb]\d+)/g){
	$_= $1;
	my @array = m/([agryb]\d+)/g;
	my $null= ($_[6] eq "+" ) ?	(&positive($_[0],$_[6],$_[3],@array)) : (&negative($_[0],$_[6],$_[4],@array));
	}
}
#----- sub section
sub positive($$$@){          # id  strand start/end pos
	my $tag = shift;
	my $str = shift;
	my $pos = shift;
	my @ac= @_;
	my $i=0;
	for($i=0;$i<=$#ac;){
		if($ac[$i]=~/([agryb])(\d+)/){
			my $tc = $1;
			my $pc = $pos + $2-1; 
			my $next=$ac[$i+1]||"NULL";######
			if (($tc eq 'b') &&( $next eq "NULL")) {
		$pc --;
					print "$tc\t$pc\t$str\t$tag\t@ac\n";  # A print now
					last;
			}
else {
			for my $j (1..$num{$tc}){
	print "$tc\t$pc\t$str\t$tag\t@ac\n";  # A print now
				$pc ++;
	}
		}
				$i+= $hash{$tc};   # update i
	}
	}
}

sub negative($$$@){          # id  strand start/end pos
	my $tag = shift;
	my $str = shift;
	my $pos = shift;
	my @ac= @_;
	my $i=0;
	for($i=0;$i<=$#ac;){
		if($ac[$i]=~/([agryb])(\d+)/){
			my $tc = $1;
			my $pc = $pos-($2-1); 
			my $next=$ac[$i+1]||"NULL";######
			if (($tc eq 'b') &&( $next eq "NULL")) {
				$pc ++;
				print "$tc\t$pc\t$str\t$tag\t@ac\n";  # A print now
				last;
			}
			else{
			for my $j (1..$num{$tc}){
			print "$tc\t$pc\t$str\t$tag\t@ac\n";  # A print now
				$pc --;
			}}
				$i+= $hash{$tc};   # update i
		}
	}
}
