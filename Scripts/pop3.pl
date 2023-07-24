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
#      VERSION:  3.1  fix 2.0 bug (rj) fix 3.0 == bug
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
    split;
    $hash{$_[0]} = ++$n;
    print STDERR "$_[0]\t$hash{$_[0]}\n";
}
#my @header = qw(#Chr    Pos     Ref     CancerDepth   1st     2nd     1stFre  2ndFre
#A       C  G       T NormalDepth 1st 2nd 1stFre 2ndFre A C G T0);
#print join("\t",@header),"\n";

open F, $ARGV[0]|| die "Could not open A";
open R, $ARGV[1]|| die "Could not open B";
my ($f, $r);
my (@f, @r);
$r =<R>;
@r = split /\s+/,$r;
$f =<F>;
@f = split /\s+/,$f;

while(1){
#    print "$f[0]\t$f[1]\t$hash{$f[0]}\t$r[0]\t$r[1]\t$hash{$r[0]}\t";
    if ($hash{$f[0]} == $hash{$r[0]}){
        if($f[1] == $r[1]){
            &print_f(); 
#            &print_chr_pos();
            &read_r();
            &read_f();
        last unless(defined $r);
        last unless(defined $f);
        }
        elsif ($f[1] >$r[1]){
            &read_r();
        last unless(defined $r);
        }
        elsif ($f[1]< $r[1]){
            &read_f();
        last unless(defined $f);
        }
    }
    elsif($hash{$f[0]} > $hash{$r[0]}){
        &read_r();
        last unless(defined $r);
    }#els    
    elsif($hash{$f[0]} < $hash{$r[0]}){
        &read_f();
        last unless(defined $f);
    }

}


#------ sub
sub print_f(){
    #  if ($f[6]>0||$f[7]>0||$f[8]>0||$f[5]>0||$r[6]>0||$r[7]>0||$r[8]>0||$r[5]>0){
    #    my @new = @f[0,1,2,3,5,6,7,8];
    my @new = @f ;
        push (@new,@r[3,4,5,6,7,8,9,10,11]);
        print join ("\t",@new),"\n";
        #}

}
sub print_chr_pos(){
    print $f[0],"\t",$f[1],"\n";
}
sub read_f(){
    $f = <F>;
    chomp $f;
    @f = split /\s+/,$f;
}
sub read_r(){
    $r = <R>;
    chomp $r;
    @r = split /\s+/,$r;
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
# single pop script
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
