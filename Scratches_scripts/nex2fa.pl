#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./nex2fa.pl  
#
#  DESCRIPTION:  Covert nex format to fa similar format
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  11/28/2012 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();
use FileHandle;
my %fh;
my $fh; 

while(<>) {
    chomp;
    split/\s+/;
    next if ($_ eq "");
    next if (/^#/);
    next if (/^\[/);
    next if (/(BEGIN|DIMEN|FORMAT|MATRIX)/i);

    my $filename = $_[0];
    #print $filename; 
    if (not exists $fh{$filename}) {
        $fh = FileHandle->new(">$filename");
        $fh{$filename} = $fh;
        print $fh ">$filename\n";
    }

    $fh = $fh{$filename};
    print $fh $_[1],"\n";
}
