#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./trans_statsV4.pl  < - >
#
#  DESCRIPTION:  Input : First two column, column three as context
#                Output: M X N Table, with column three as context
#                A B 1
#                C B 2
#                A C 3  ==> 
#
#                -   B  C
#                A   1  3
#                C   2  0
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  01/10/2012 
#===============================================================================

)
}
use strict;
#use warnings;
use Getopt::Std;
$ARGV[0] || &usage();


#our ($opt_n);
#getopts("n:");
my %hash;
my %header;
my %row;

while(my $line=<>){
    chomp $line;
    my @line = split/\s+/,$line;
    $hash{$line[0]}{$line[1]} = 1;
#    $hash{$line[0]}{$line[1]} += $line[2]; # design for ASCAT Ploidy Printing
#	$hash{$line[1]}{$line[0]} = $line[2]; # for asymatrix
	$header{$line[1]} = 1;
	$row{$line[0]} = 1;
}

my @header = (sort { $a <=> $b || $a cmp $b } keys %header);
print "Case\\Clone\t",join("\t",@header),"\n";

foreach my $key ( sort {$a <=> $b ||  $a cmp $b } keys %row) {
    print $key,"\t";
    foreach my $keys ( sort { $a <=> $b || $a cmp $b } keys %header ) {
       if (defined $hash{$key}{$keys}) {
            print $hash{$key}{$keys},"\t"; 
       }
       else {
           print "0\t";
       }
    }
    print "\n";
}
