#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./split_by_field2.pl 
#
#  DESCRIPTION:  Split with field
#                -a split with multiple field "3,5,7"
#       OUTPUT:  field3.field5.field7
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  10/25/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use FileHandle;
use Getopt::Std;
our ($opt_a);
getopts("a:");

my %fh; # record filehandle
my $fh;

my @field = split/\,/,$opt_a;
foreach (@field) {
    $_ -- ;
}

while(my $line = <>) {
    chomp $line;
    my @array = split/\s+/,$line;
    my $filename = join(".",@array[@field]);
    #print $filename; 
    if (not exists $fh{$filename}) {
        $fh = FileHandle->new(">$filename");
        $fh{$filename} = $fh;
    }

    $fh = $fh{$filename};
    print $fh $line,"\n";

}
