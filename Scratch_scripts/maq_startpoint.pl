#!/usr/bin/perl -w
#Filename:
#Author:	Du Zhenglin
#EMail:		duzhl@big.ac.cn
#Date:		
#Modified:	
#Description: 
my $version=1.00;

use strict;
use Getopt::Long;


my %opts;
GetOptions(\%opts,"i=s","o=s","z:s","h");
if (!(defined $opts{i} and defined $opts{o}) || defined $opts{h}) {			#necessary arguments
	&usage;
}


my $filein=$opts{'i'};
my $fileout=$opts{'o'};

my $idxfile="";

my $read_length=35;

my $column=2;			#column for id
my @buffer;
my @block;			#id->[0] startline->[1] endline->[2]
my $id;
my $last_id="";
my @info;
my $counter=0;
my $link_str;
my $line;

my @ref_startpoint;
my @ref_startpoint_reverse;
my $ref_id;
my $start=0;
my $orient;

my $startpoint_type=0;
my $ref_end;
my $border;
my $all_startpoint=0;

open IN,"<$filein";

while (my $aline=<IN>) {
	push(@buffer,$aline);
	chomp($aline);
	@info=split /\t/,$aline;
	$id=$info[$column-1];
	if($id ne $last_id){
		$block[$counter][0]=$id;
		$block[$counter][1]=$#buffer;					#start line
		$block[$counter-1][2]=$#buffer-1 unless($last_id eq "");	#last line of last block
		
		$counter++;
		$last_id=$id;
	}
	if(eof(IN)){
		$block[$counter-1][2]=$#buffer;					#last line
	}
}
print "Total blocks: ".($#block+1)."\n";

if(defined $opts{z}){
	$idxfile=$opts{z};
	if($idxfile ne ""){
		open IDX,">$idxfile";
		for(my $i=0;$i<=$#block;$i++){				#show what in the index/block
			$link_str=join("\t",@{$block[$i]});
			print IDX "$i\t$link_str\n";
		}
	}else{
		for(my $i=0;$i<=$#block;$i++){			
			$link_str=join("\t",@{$block[$i]});
			print "$i\t$link_str\n";
		}		
	}
};

$counter=0;


for(my $i=0;$i<=$#block;$i++){
	$ref_startpoint[$i][0]=$block[$i][0];		#reference id
	for(my $j=$block[$i][1];$j<=$block[$i][2];$j++){
		$line=$buffer[$j];
		@info=split(/\t/,$line);
		$ref_id=$info[1];
		$start=$info[2];
		$orient=$info[3];
		
		if($orient eq "+"){
			if(defined $ref_startpoint[$i][$start]){
				$ref_startpoint[$i][$start]++;
			}else{
				$ref_startpoint[$i][$start]=1;
			}			
		}else{
			if(defined $ref_startpoint_reverse[$i][$start+$read_length-1]){
				$ref_startpoint_reverse[$i][$start+$read_length-1]++;
			}else{
				$ref_startpoint_reverse[$i][$start+$read_length-1]=1;
			}
		}
	}
}

open OUT,">$fileout";
for(my $i=0;$i<=$#ref_startpoint;$i++){
	$ref_end=max($#{$ref_startpoint[$i]},$#{$ref_startpoint_reverse[$i]});
	for(my $j=1;$j<=$ref_end;$j++){
		$border=max($j-$read_length+1,1);
		for(my $m=$border;$m<=$j;$m++){				#forward startpoint
			if(defined $ref_startpoint[$i][$m]){
				$startpoint_type++;
			}
		}
		$border=min($j+$read_length-1,$ref_end);
		for(my $m=$j;$m<=$border;$m++){
			if(defined $ref_startpoint_reverse[$i][$m]){	#reverse startpoint
				$startpoint_type++;
			}
		}
		
		print OUT "$ref_startpoint[$i][0]\t$j\t$startpoint_type\t";
		if(defined $ref_startpoint[$i][$j]){
			print OUT "$ref_startpoint[$i][$j]\t";
			$all_startpoint+=$ref_startpoint[$i][$j];
		}else{
			print OUT "0\t";
		}
		if(defined $ref_startpoint_reverse[$i][$j]){
			print OUT "$ref_startpoint_reverse[$i][$j]\t";
			$all_startpoint+=$ref_startpoint_reverse[$i][$j];
		}else{
			print OUT "0\t";
		}
		print OUT "$all_startpoint\n";
		
		$startpoint_type=0;
		$all_startpoint=0;
	}
}



#############SUB###############
sub max{
	my ($A,$B)=@_;
	if ($A<$B) {
		return $B;
	}else{
		return $A;
	}
}

sub min{
	my ($A,$B)=@_;
	if ($A<$B) {
		return $A;
	}else{
		return $B;
	}
}

sub usage{
	print <<"USAGE";
Version $version
Usage:
	$0 -i <input file> -o <output file>
options:
	-i input map.txt file
	-o output file
	-z statistics
	-h help
USAGE
	exit(1);
}

