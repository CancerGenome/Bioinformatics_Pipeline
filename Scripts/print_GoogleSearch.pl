#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/print_GoogleSearch.pl  -h
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 19 Jun 2020 09:32:58 AM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

while (my $line = <>){
    chomp $line;
    my @F = split/\s+/,$line;
	#print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:yyk85pvjw50&q=\"$F[0]\"+dissection \" > $F[0].dissection.json\n"; # next step
	#print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:yyk85pvjw50&q=\"$F[0]\"+aneurysm \" > $F[0].aneurysm.json\n"; # next step
	#print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:yyk85pvjw50&q=\"$F[0]\"+dissection+aneurysm \" > $F[0].dis.aneurysm.json\n"; # next step
	#print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:yyk85pvjw50&q=\"$F[0]\"+fibromuscular+dysplasia \" > $F[0].fmd.json\n"; # next step
	#print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:yyk85pvjw50&q=\"$F[0]\"+cardiovascular \" > $F[0].cardio.json\n"; # next step
	#print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:yyk85pvjw50&q=\"$F[0]\"+fibromuscular+dysplasia+dissection+aneurysm+cardiovascular \" > $F[0].all.json\n"; # next step
	# Back up server
	print "curl \"https://www.googleapis.com/customsearch/v1?key=AIzaSyDwKdJByDW79IQZewhSIWgsBCOPu_yP2X0&cx=017382258190500323974:ji57jw7ztcm&q=\"$F[0]\"+fibromuscular+dysplasia+dissection+aneurysm+cardiovascular \" > $F[0].all.json\n"; # next step

}
