#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/varscan_convert.pl  -h -r
#        DESCRIPTION: -h : Display this help
#                     -r : Reverse NT and print different header
#
#        Convert Varscan SNP file to : chr, pos, dbsnp, status, tref, tvar, tfreq, nref, nvar, nfreq
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 10 Feb 2017 03:51:30 PM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_r);
getopts("hr");

if($opt_r){
	print "Chr\tPos\tVR.dbsnp\tVR.Status\tVR.tref\tVR.tvar\tVR.tfreq\tVR.nref\tVR.nvar\tVR.nfreq\n";
}
else{
	print "Chr\tPos\tV.dbsnp\tV.Status\tV.tref\tV.tvar\tV.tfreq\tV.nref\tV.nvar\tV.nfreq\n";
}
<>; # skip header

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	print "$F[0]\t$F[1]\t","NA","\t","$F[12]\t$F[4]\t$F[5]\t", int($F[5]/($F[4]+$F[5])*100)/100, "\t$F[8]\t$F[9]\t", int($F[9]/($F[8]+$F[9])*100)/100,"\n";

}
