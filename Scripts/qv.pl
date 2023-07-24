#!/usr/bin/perl -w
#Filename: 
#Author:Zhaowenming
#EMail:
#Date: 2009-1-4
#Modified:
#Description: calculate the QV for each mismatch site.
my $version=1.00;

use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"g=s","o:s","l:i","h");
if (!(defined $opts{g} and defined $opts{o}) || defined $opts{h}) {   #necessary arguments
        &usage;
}
#================================================================
my $gfffile = $opts{g};
my $output  = $opts{o};
my $reads_length = 35;

if (defined($opts{l})){
	$reads_length = $opts{l};
}
my @mismatch_qv = ();
open (GFF, $gfffile) || die ("Could not open file $gfffile");
while(my $line=<GFF>){
	#35_1170_1031_F3 solid   read    1       35      20.2    +       .       g=A3112032020031212221021101300031023;i=1;p=1.000;q=22,29,29,31,29,33,26,31,30,31,29,31,29,27,30,31,27,25,20,19,31,30,25,28,26,16,23,16,14,27,10,22,31,12,25;u=1
	#4_678_100_F3    solid   read    1       35      13.7    +       .       b=ATGTCCGAAGGGCAGTCTCAAGTGGgccAATGGAT;g=A3112032020031212221021100301011023;i=1;p=1.000;q=23,26,30,28,30,31,21,29,27,29,25,29,26,29,27,27,22,28,15,15,31,30,25,11,19,8,15,10,7,24,5,17,13,5,10;r=26_1,29_0,31_3;s=r26,r27,r28,r29,a31;u=0,0,0,1
	#if($gff_str[$n] =~ /\w+\t\w+\t\w+\t(\d+)\t(\d+)\t\-1\t(\S+)\t\S+\t(b=\w+)?;g=\w+;i=\d;p=(\d\.\d+);(r=(((,)?\w+)+);)?(s=(((,)?\w+)+);)?u=(\S+)/)
	if($line =~ /\w+\t\w+\t\w+\t(\d+)\t(\d+)\t\S+\t(\S+)\t\S+\t(b=\w+)?;g=\w+;i=\d;p=(\d\.\d+);(q=((\d+,?)+);)?(r=((,?\w+)+);)?(s=((,?\w+)+);)?u=(0,)/){
    	my $rstart  = $1;
    	my $rend    = $2;
			my $direction = $3;
			my @reads_qv = split(/,/,$7);            #q=(35,22,.....)
			my @color_error_site  = split(/,/,$10);  #r=(22_2,35_3)
	  	#my $error_info        = $13; #s=(a22,a35)
	  	#my $mismatch_info     = $15; #u=(0,0,1)
	  	#my @mismatch_vector   = split(",", $mismatch_info);
	  	#my @color_pos = split(",", $color_error_site);
	  	for (my $k=0; $k<@color_error_site; $k++){
			 	$color_error_site[$k] =~ /(\d+)_/;
			 	$mismatch_qv[$reads_qv[$1-1]] += 1;
	  	}
	  }
	
}
open (OUT,">$output");
my $qv = "";
my $qu = "";
for (my $i=1; $i<@mismatch_qv; $i++){
	$qv .= "$i,";
	if (defined($mismatch_qv[$i])){
		$qu .= $mismatch_qv[$i] . ",";
	}else{
		$qu .= "0,";
	}
}
chop($qv);
chop($qu);
print OUT "$qv\n";
print OUT "$qu\n";

close OUT;

#===============================================================
sub usage{
        print <<"USAGE";
Version $version
Usage:
        $0 -g <gff file> -o <output file>
options:
        -g input annotate.gff file
        -o output file
        -l reads length (default 35)
        -h help
USAGE
        exit(1);
}