#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./sel_read.pl  
#
#  DESCRIPTION:  INPUT file :<SORT id>  <TARGET FILE>
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/09/2009 
#===============================================================================

		  )
}
use strict;
use warnings;

$ARGV[0] || &usage;
my ($read_id,$seq,$qua);
my $cache;

	open IN, "$ARGV[1]";
	open Q, "$ARGV[0]";
	my $line =<Q>;
	chomp $line;
	&read;
	while (1){
		last unless ($line);
		last unless ($read_id);
		if ($line eq $read_id) {
			print "$cache\n$seq\n+\n$qua\n";	
			$line=<Q>;
			chomp $line;
			&read;
		}
		else {
		&read;
		}
		
	}
	close IN;



sub read(){
	$cache = <IN>;
	chomp $cache;
	$cache =~ /(rc\d:\d+_\d+_\d+)/;
	$read_id = $1;
#	print "$read_id\n";
	$seq = <IN>;
	chomp $seq;
	my $a= <IN>;
	$qua = <IN>;
	chomp $qua;
}
