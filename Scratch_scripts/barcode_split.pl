#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./split_via_barcode.pl -l [Barcode list] -f [FQ file] -n [Barcode length:7]
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  02/22/2011 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;

# get option
our ($opt_l,$opt_h,$opt_f,$opt_n);
getopt("l:f:hn:");
&usage if ($opt_h);
&usage unless ($opt_l);

# open FileHandle
my @list = `cut -f1 $opt_l`;
my %fh;
$opt_n = 7 if (not defined $opt_n);

chomp @list;
push (@list,'ELSE');
#print STDERR @list;
foreach my $list (@list) {
    open ($fh{$list}, "| gzip > $list.fq.gz") || die ("** Failed to open $list.fq");
}

my %hash;
my $tag = 0;

open FQ, "$opt_f";
while(<FQ>) {
    chomp;
    open IN, "$_";
    while(my $line = <IN>) {

        $_= <IN>;
#        print STDERR substr($_,0,$opt_n);
        if( $fh{substr($_,0,$opt_n)} ){
            select $fh{(substr($_,0,$opt_n))} ;
            $tag = 0;
        }
        else {
            select $fh{"ELSE"} ;
            $tag = 1; # ELSE will print all non-exists data, do not split
        }

        print $line;
        print substr($_,$opt_n,75) if ( $tag == 0 );
        print $_ if ( $tag == 1 );
        $hash{substr($_,0,$opt_n)}++;
        $_ = <IN>;
        print;
        $_ = <IN>;
        print substr($_,$opt_n,75) if ( $tag == 0 );
        print $_ if ( $tag == 1 );


        select STDERR;
    }
    close IN;
}

open OUT,">Barcode.stat";

foreach my $key (keys %hash) {
	print OUT "$key\t$hash{$key}\n";
}
`sort -k2n,2r Barcode.stat > cache; mv cache Barcode.stat`;
