#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./rmAdjError.pl  <STDIN>  
#                -f : filed of position, start from 1, default :2 
#                -d : addjacent distance, default : 1
#                -h : display this hlep
#
#  DESCRIPTION:  Remove all adjacent error, input file must be sorted 
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  04/15/2010, update_lineate 06/07/2018
#===============================================================================

)
            }
use strict;
use warnings;

use Getopt::Std;
our ($opt_f,$opt_h,$opt_d);
$opt_d = 1 ;
getopt("f:hd:");
&usage if ($opt_h);
&usage unless ($ARGV[0]);

my ($last_pos,$last_line)=qw(0 0);
my $field = $opt_f || 2 ;
my $last_line_should_remove = 0 ; # whether last line should be removed or not
$field -- ;

open IN, $ARGV[0];

    my ($line,@F) ;
    $line = <IN>;
    chomp $line;
    @F = split/\s+/,$line;
    &update_line();

while(1) {
    if ($F[$field]-$last_pos > $opt_d or $F[$field]-$last_pos < 0) {
		if($last_line_should_remove == 0 ){
			#print "Update1\t$last_line\n";
			#print "Update1\t$line\n\n";
			print "$last_line\n";
		}else{
			#print "FAILED\t$last_line\n";
		}
        &update_line();
		$last_line_should_remove = 0 ;
    }else{ # pos in range
#		<IN>; # like nothing happen
		#print "Update2.1\t$last_line\n";
		#print "Update2.1\t$line\n";
        &update_line();
		$last_line_should_remove = 1;
		#	print "Update2.2\t$last_line\n";
		#print "Update2.2\t$line\n\n";
        
    }
}

sub update_line (){

    if (eof(IN)) {
        print "$line" if ( $F[$field]-$last_pos > $opt_d or $F[$field]-$last_pos < 0 );
        last;
    }
    else {
        $last_pos = $F[$field];
		#print "LAST Number: $last\n";
        $last_line = $line;
        $line = <IN>;
        chomp $line;
        @F = split/\s+/,$line;
    }
}
