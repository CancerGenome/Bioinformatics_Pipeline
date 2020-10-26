#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./bwa_depth.pl  <INPUT>  <WINDOW_SIZE>
#
#  DESCRIPTION:  To give bwa sam file depth per windows / has small error rate of 1%
#								
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  11/23/2009 
#===============================================================================

		  )
}
use strict;
use warnings;
$ARGV[1]||&usage(); 
# default at one chromosome
my $window = $ARGV[1];
my ($cur,$next); # cur depth next depth
my ($last_win, $cur_win);
my ($len,$pos);
$last_win = 0;
$cur_win = $window;

open IN, "$ARGV[0]";
&read_sam();
while(1){

		 if ($pos+$len <= $cur_win){
			 $cur += $len;
			 &read_sam();
		 }
		 elsif ($pos > $cur_win){
			 $cur /= $window;
		 	print $cur_win,"\t",$cur,"\n"; 
			$cur_win += $window;
			$cur = $next;	
			$next = 0;
		 }	
		 elsif ($pos + $len > $cur_win and $pos <= $cur_win) { 
		 	$cur += ($cur_win - $pos +1);
			$next += ($len-($cur_win-$pos +1));
			&read_sam();
		 }
}
		 $cur /= $window;
		 print $cur_win,"\t",$cur,"\n" ;
		 $cur_win += $window;
		 $next /= $window;
		 print $cur_win,"\t",$next,"\n" if ($next !=0);

			 
sub read_sam(){
	
	my $a = <IN>;
	last if not defined ($a);
	chomp $a;
	my @a = split/\s+/,$a;
	next if ($a[5] eq "*");
	$pos = $a[3];
	$_ = $a[5];
		my @array = m/([0-9]+)[MIDNSHP]/g;
		$len = 0;
			foreach my $num (@array){
				$len += $num;
			}
#			print STDERR $len,"\n";

}
