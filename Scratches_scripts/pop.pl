#!/usr/bin/perl 
sub usage(){
	die qq(
#===============================================================================
#
#        USAGE:  ./pop.pl  <F3 file> <R3 file>;  F3 head must bigger than R3
#
#  DESCRIPTION:   Compare two files and output same items between two files
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  08/14/2009 11:32:21 AM
#===============================================================================

)
}
use strict;
use warnings;

$ARGV[0]|| &usage();
open F, $ARGV[0]|| die "Could not open A";
open R, $ARGV[1]|| die "Could not open B";
my ($f, $r);
#=head
while($f = <F>){chomp $f;last;}
while($r = <R>){chomp $r;last;}
while(1){
	if($f eq $r){
		print "$f\n";
		while($f = <F>){chomp $f;last;}
		last unless(defined $f);
		while($r = <R>){chomp $r;last;}
		last unless(defined $r);
	} elsif($f lt $r){
		while($f = <F>){chomp $f;last;}
		last unless(defined $f);
	} else {
		while($r = <R>){chomp $r;last;}
		last unless(defined $r);
	}
}
close F;
close R;
=cut
while(my $f= <F>){
	chomp $f;
	$r || ($r = <R>);
	last unless(defined $r);
	chomp $r;

	if ($f eq $r ){
		print $f,"\n";
		$r =<R>;
		last unless(defined $r);
	}

	elsif($f gt $r){
		while(($f ge $r) && !(eof R) ){
		 $r =<R>;chomp $r;	
			if ($f eq $r){
				print $f,"\n"; $r=<R>; chomp $r;
			}
		}
	}	

}
