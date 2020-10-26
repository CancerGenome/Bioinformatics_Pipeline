#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/Get_LD_1000G_EUR.pl  -h
#        DESCRIPTION: -h : Display this help
#        Input should be rsid (first column)
#        Window Size 1000000 on each side
#        Use LDlink 1000G EUR data 
#
#        -m: MAF threshold, remove variants below this, default: 0.1
#        -r: threshold for r^2, default: 0.2
#
#        Version Note: output segment of 0.2 automatically, source code from Get_LD_Segment.pl
#
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 17 Sep 2020 11:06:05 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_m,$opt_r);
getopts("m:r:h");
if(not defined $opt_m){
	$opt_m = 0.1;
}
if(not defined $opt_r){
	$opt_r = 0.2;
}


while (my $line = <>){
    chomp $line;
    my @F = split/\s+/,$line;
	#print "Start: $F[0]\n";
	`sleep 2`;
	`curl -k -X GET 'https://ldlink.nci.nih.gov/LDlinkRest/ldproxy?var=$F[0]&pop=CEU%2BTSI%2BFIN%2BGBR%2BIBS&r2_d=r2&token=f4a4b0496090&window=1000000' > $F[0].EUR.LD`;

	## Print Segments for each file
	my $file = "$F[0].EUR.LD";
	open IN, $file;
	<IN>;
	my $chr = "chr1";
	my $min = 100000000000 ;
	my $max = 0 ;
	while (my $line = <IN>){
		chomp $line;
		my @F = split/\s+/,$line;
		next if($F[3] < $opt_m); # MAF > 0.1
		next if($F[6] < $opt_r); # r^2 0.8
		my @G = split/:/,$F[1];
		$chr = $G[0];
		$chr =~ s/chr//;
		if($min > $G[1]){
			$min = $G[1];
		}
		if($max < $G[1]){
			$max = $G[1];
		}
	}
	if($min == $max){
		$min = $min -1;
	}
	print "$chr\t$min\t$max\t$file\n";
	close IN;
}
