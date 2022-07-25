#!/usr/bin/perl 
sub usage(){
    die qq(
#===============================================================================
#
#        USAGE:  ./statis.pl <STDIN/-> 
#                -c field number of column '1,2;11,12', use 1,2 as keys of hash1, use 11,12 as keys of hash2
#                -s Separator [\s+]
#
#  DESCRIPTION:  Statistics column result ,like sort | uniq -c 
#       OUTPUT:  Hash_index,Key_one,Key_two,...,Total_number based on above keys
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  06/03/2009 04:57:01 PM
#===============================================================================
)
}
use strict;
#use warnings;
use Getopt::Std;

our ($opt_c,$opt_h,$opt_s);
getopt("c:hs:");
&usage if ($opt_h);
&usage unless ($ARGV[0]);
$opt_s = '\s+' unless ($opt_s);

open IN, $ARGV[0];
my @array; # record for line
my @col; # for field of column 
my @hash; # array of hash reference
my $tag = 0;

# ------get  Column numbers ------ 
    my $line = <IN>;
    @array = split/$opt_s/,$line;

    if ($#array == 1 ) {
        @{$col[0]} = qw(0 1);
    }
    else {
        @{$col[0]} = qw(0);
    }

    if ($opt_c) {
        my @c = split/\;/,$opt_c; # 1,2  3,5  4,6
        for my $i(0..$#c) {
            my @a = split/\,/,$c[$i]; # $a[0] 1 2 , $a[1] 3 5 , $a[2] 4 6
            foreach (@a) {
                $_--;
            }
            @{$col[$i]} = @a ; # record as hash array
#            print join("\t",@a),"\n";
        }
#        print join("\t",@tag),"\n";
    }
    &count();

    while(<IN>){
        chomp;
        @array = split /$opt_s/;
        &count();
    }
     &print();
#-------  SUB  -------------
sub print() {
    for my $i(0..$#col) {

        my %hash = %{$hash[$i]};
        foreach my $key (sort {$a <=> $b or $a cmp $b } keys %hash) {
            print chr(65+$i),"\t" if ($#col >= 1) ;
            print "$key\t$hash{$key}\n";
        }
    }
}

sub count(){
    for my $i (0..$#col) {
        #print "$i\n";
        my @subcol = @{$col[$i]}; # get subcol 
        $hash[$i]->{join("\t",@array[@subcol])} ++;
    }
}
