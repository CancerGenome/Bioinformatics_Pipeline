#!/usr/bin/perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

# Validate and concatenate a reference sequence

# major modification on SEPT06 2007 by charles scafe.
# this modification allows large sequences to be processed without swamping
# out the memory resources.  Instead of creating a full sequence object for 
# validation purposes, the validation is handled via streaming.  In addition
# the concatenation and validation are done in the same subroutine, speeding 
# up the process.

use strict;
use warnings;

#no longer used. crs 090607.
#use dna_subroutines;

BEGIN {
    # This forces FindBin to find the script in the current working directory
    $ENV{'PATH'} = ".:" . $ENV{'PATH'};
}

use FindBin;
#no longer used crs 090607
#use File::Temp qw/tempfile/;
$ENV{'PATH'} = ${FindBin::Bin} . ":" . $ENV{'PATH'};

my $parameters = {};

sub usage {
    print "\nUsage: $0 \n\n\t ";
    print "-r <reference_file> \n\t ";
    print "-s <reference_size_limit> \n\t ";
    print "-o <outputfile> \n\n";
    exit(1);
}
if(scalar(@ARGV) == 0){
    usage();
}

# Parse the Command Line
&parse_command_line($parameters, @ARGV);

# Verify Input
&verify_input($parameters);

# dos2unix
print "\ndos2unix...\n";
system("dos2unix $parameters->{reference_file}");




# concatenate and validate
print "\nconcatenating...\n";
print "\nchecking for non-standard characters...\n";

# Create a temporary file name for the concatenated sequence
#no longer used crs 090607

#my($fh, $filename) = tempfile( "concatenated_XXXXX" );
#close $fh;
#$parameters->{concatenated_file} = $filename;
#system("concatenate_sequences.pl -f $parameters->{reference_file} -o $parameters->{concatenated_file} -h concatenated");

#call new subroutine to concatenate seqs and check for non-standard characters.
#returns length of sequence for checking if length exceed max length. crs 090607

my $reference_length = &concatenate_and_validate($parameters->{reference_file}, $parameters->{outputfile}, 'validated');

# size limit
print "\nchecking size...\n";

#no longer used crs 090607
#my($reference_header, $reference_sequence, $reference_length) = &process_fasta_file($parameters->{concatenated_file});

if($reference_length > $parameters->{reference_size_limit}){
    print "\n";
    print "ERROR: Reference size ($reference_length bases) is too large\n";
    print "       Reference must be <= $parameters->{reference_size_limit} bases\n";
    print "\n";
    unlink($parameters->{outputfile});
    exit(1);
}

# non-standard characters

# used only in new subroutine crs 090607
#$reference_sequence =~ tr/[A,C,G,T,N,a,c,g,t,n,\.]/N/c;
#$reference_sequence =~ tr/acgtn/ACGTN/;

# outputfilef
# no longer used.  file is written by new subroutine crs 090607

#print "\ngenerating validated reference file...\n\n";
#unless ( open(FASTA, ">$parameters->{outputfile}") ) {
 #   print "Cannot open file \"$parameters->{outputfile}\" to write to!!\n\n";
  #  exit;
#}
#print FASTA ">validated\n";
#&print_sequence($reference_sequence, 70, \*FASTA);
#close(FASTA);

# Remove the temporary concatenated file
#no longer used crs 090607
#unlink($parameters->{concatenated_file});


exit;


sub parse_command_line {

    my($parameters, @ARGV) = @_;

    my $next_arg;

    while(scalar @ARGV > 0){
	$next_arg = shift(@ARGV);
	if($next_arg eq "-r"){ $parameters->{reference_file} = shift(@ARGV); }
	elsif($next_arg eq "-s"){ $parameters->{reference_size_limit} = shift(@ARGV); }
	elsif($next_arg eq "-o"){ $parameters->{outputfile} = shift(@ARGV); }
	else { print "Invalid argument: $next_arg"; usage(); }
    }
}


sub verify_input {

    my($parameters) = @_;

    my($i, $temp);
    my @values = ();

    print "\n";

    # reference_file
    if(-e $parameters->{reference_file}){ 
	print "  reference_file = $parameters->{reference_file} \n"; 
    } 
    else{ 
	print "\n  ERROR: reference file $parameters->{reference_file} does not exist \n"; 
	usage(); 
    }

    # reference_size_limit
    if(defined $parameters->{reference_size_limit}){
	if ($parameters->{reference_size_limit} =~ /^-?\d/){
	    if($parameters->{reference_size_limit} > 0){ 
		print "  reference_size_limit = $parameters->{reference_size_limit} \n"; 
	    } 
	    else{
		print "\n  ERROR: invalid reference_size_limit \n"; 
		usage(); 
	    }
	} 
	else{ 
	    print "\n  ERROR: invalid reference_size_limit \n"; 
	    usage(); 
	}
    }
    else{ 
	print "\n  ERROR: reference size limit not defined \n"; 
	usage(); 
    }
}

# this subroutine combines checking for non-standard characters with concatenation 
# by using a streaming strategy instead of loading the entire sequence into memory crs 090607

sub concatenate_and_validate {
    my $i;
    my $length = 0;

    my($fasta_file, $outputfile, $header) = @_;

    #if(scalar(@ARGV) == 0){
	#print "Usage: $0 -f <fasta_file> -o <outputfile> -h <header> \n";
	#exit(1);
    #}

# Parse the command line
    #while(scalar @ARGV > 0){
	#$next_arg = shift(@ARGV);
	#if($next_arg eq "-f"){ $fasta_file = shift(@ARGV); }
	#elsif($next_arg eq "-o"){ $outputfile = shift(@ARGV); }
	#elsif($next_arg eq "-h"){ $header = shift(@ARGV); }
    #}

# Output
    unless ( open(FASTA, ">$outputfile") ) {
	print "Cannot open file \"$outputfile\" to write to!!\n\n";
	exit;
    }
    print FASTA ">$header\n";

# Fasta File
    open( FILE, "< $fasta_file" ) or die "Can't open $fasta_file : $!";
    my $sequence = '';
    my $count = 0;
    my @array = ();
    my $space_counter = 0;
    my $line_width = 70;
    while( <FILE> ) {
	chomp;
	$_ =~ s/^\s+//;
	$_ =~ s/\s+$//;
	if( $_ =~ /^>/ ){
	    $count++;
	    if($count > 1){
		print FASTA ".";
		$space_counter++;
		if($space_counter == $line_width){
		    print FASTA "\n";
		    $space_counter = 0;
		}
	    }
	}
	# Check for a blank line
	elsif (/^(\s)*$/){
	    $sequence = '.';
	}
	else{
	    tr/[A,C,G,T,N,a,c,g,t,n,\.]/N/c;
	    tr/acgtn/ACGTN/;
	    $length += length($_);
	    @array = ();
	    @array = split(//, $_);
	    
	    
	    for($i = 0; $i < length($_); $i++){
		print FASTA $array[$i];
		$space_counter++;
		if($space_counter == $line_width){
		    print FASTA "\n";
		    $space_counter = 0;
		}
	    }
	}
    }
    print FASTA "\n";
    close(FASTA);
    close(FILE);
    return($length);
}



