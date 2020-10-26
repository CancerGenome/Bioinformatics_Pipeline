#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/fastPHASE2phase_input.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 10 Oct 2019 10:30:40 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $line1 = <>;
my $line2 = <>;
chomp $line2;
my $line3 = <>;
my $line4 = "S" x $line2;
print STDERR "STDERR: Length: $line2\n";

print $line1,$line2,"\n",$line3,$line4,"\n";

while(my $line = <>){
	chomp $line;
	$line =~ s/\s+//g;
	print $line,"\n";
}
