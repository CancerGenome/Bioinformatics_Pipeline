#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./countbase.pl  <STDIN>
#                -s Separator [default NULL, AAA -> A,A,A]
#                -b Biggest number your count [3]
#                -h Display this 
#                -q Qual model give number 1  ( do not compatiable with s b )
#
#  DESCRIPTION:  Count solid distribution of per base 
#       OUTPUT:  X-axis: Position, Y-axis: Numbers
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/24/2010 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;

our($opt_s,$opt_h,$opt_b,$opt_q);
getopt("s:hb:q:");

&usage if ($opt_h);
&usage unless ($ARGV[0]);
#print "$opt_s\n" if ($opt_s);
if ($opt_q) {
	$opt_b = 40;
	$opt_s = '\s+';
}

my %hash;
my $arrayl;

while(<>) {
    next if/\>/;
    chomp;
    my @array;
    if ($opt_s){
        @array = split/$opt_s/;
    }
    else {
        @array = split//;
    }

    foreach my $i(0..$#array){
	next if ( $array[$i] !~/[0-9]+/);
        if ($array[$i] < 0 ) {
            $array[$i] = 0 
        }
        $hash{$i}{$array[$i]} ++ ;
    }
    $arrayl = $#array;
}

if (not defined $opt_b) {
    $opt_b = 3;
}

#    print "$opt_b\n";
#    print "$arrayl\n";
    for my $i(0..$opt_b){
        for my $j (0..$arrayl) {
            if ($hash{$j}{$i}) {
                    print $hash{$j}{$i};
                    print "\t";
            }
            else {
                print "0\t";
            }
        }
        print "\n";
    }

=head
# possible used Rscript
file = list.files(pattern="*.qual.stat")
for (i in 1:length(file)) {
    a = read.table(c(file[i]))
    data = t(a)
    data = data/rowSums(data)
#    png( paste(c(file[1],".png"),sep="") )
    png( paste(file[i],".png",sep="") ) 
    image((1:nrow(data)), (1:ncol(data)), (as.matrix(data)), col=gray((32:0)/32), ylab="Quality value", xlab="Position of read",main=paste(file[i],"quality distribution" ) )
    dev.off()
}

