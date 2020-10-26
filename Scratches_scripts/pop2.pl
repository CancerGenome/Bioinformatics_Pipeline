#!/usr/bin/perl 
sub usage(){
	die qq(
#===============================================================================
#
#        USAGE:  ./pop.pl  <F3 file> <R3 file> <Chr_Order>;  F3 head must bigger than R3
#
#  DESCRIPTION:   Compare two fields of files and output same items between two files
#                 Chr_filed can be disorder, but pos must be order.
#                 Should give a file contain chr list			
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  2.0
#      CREATED:  08/14/2009 11:32:21 AM
#===============================================================================

)
}
use strict;
use warnings;

if ($ARGV[0] eq "-h" or $ARGV[0] eq "-help") {&usage()};
$ARGV[2]|| &usage();

open HASH, $ARGV[2];
my %hash;
my $n=0;
while(<HASH>){
	chomp;
	$hash{$_} = ++$n;
#	print "$hash{$_}\n";
}

open F, $ARGV[0]|| die "Could not open A";
open R, $ARGV[1]|| die "Could not open B";
my ($f, $r);
my (@f, @r);
=head
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
$r =<R>;
@r = split/\s+/,$r;
while($f= <F>){
	chomp $f;
	last unless(defined $r);
	chomp $r;
	 @f = split/\s+/,$f;
	 
	if ($hash{$f[0]} == $hash{$r[0]}){
		if($f[1] == $r[1]){
			&print_f(); 
			&read_r();
			&read_f();
		last unless(defined $r);
		}
		while($f[1] > $r[1] && $hash{$f[0]} >= $hash{$r[0]}){  #update r
			&read_r();
			last unless(defined $r);
			if($f[1] == $r[1]){
				&print_f(); 
				&read_r();
			last unless(defined $r);
		}
		}
	}
	elsif($hash{$f[0]} > $hash{$r[0]}){
		while(($hash{$f[0]} > $hash{$r[0]}) && !(eof R) ){
				&read_r();
			if ($hash{$f[0]} == $hash{$r[0]}){
				if ($f[1] == $r[1]){
					&print_f(); 
					&read_r();
				}
			}
		}
	}	

}


#------ sub
sub print_f(){
	if ($f[6]>0||$f[7]>0||$f[8]>0||$f[5]>0||$r[6]>0||$r[7]>0||$r[8]>0||$r[5]>0){
		my @new = @f[0,1,2,3,5,6,7,8];
		push (@new,@r[3,5,6,7,8]);
		print join ("\t",@new),"\n";
	}

}
sub read_f(){
	$f = <F>;
	chomp $f;
	@f = split/\s+/,$f;
}
sub read_r(){
	$r = <R>;
	chomp $r;
	@r = split/\s+/,$r;
}

#------  NOTE POP
=head
if (a ture){
	if (b ture){
		print and update
	}
	elsif (b1 is great){
		update b2
	}
	elsif (b2 is great){
		update b1
	}
}

elsif (a1 is great){
	update a2
}
elsif (a2 is great){
	update a1
}
