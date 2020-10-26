#!/usr/bin/perl 
sub usage(){
    die qq(
#===============================================================================
#        USAGE:  ./quniq_plot.pl <Input>  <Prefix of title> <xlab> <ylab>
#
#  DESCRIPTION:  plot quniq data (two-dimension only) second as x-axis third as y-axis, log transformation for forth column
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  06/03/2009 04:57:01 PM
#===============================================================================
)
}
use strict;
use warnings;
use FileHandle;
&usage unless ($ARGV[0]);

my @b;
my %hash;
my %seen;
my $title = $ARGV[1] || "Title" ;
my $xlab = $ARGV[2] || "xlab" ;
my $ylab = $ARGV[3] || "ylab" ;

open IN, $ARGV[0];
while(<IN>) {
    chomp;
    s/-/0/g;
    split;
    $hash{$_[0]}{$_[1]}{$_[2]} = $_[3];
    push(@b,$_[0]);
}

my @a = grep {not $seen{$_}++ } @b ;
#print join("\t",@a);

foreach my $a(@a) {
        my $f = FileHandle->new(">$a");
    for my $i(0..100) {
        for my $j(0..100) {
            if ($hash{$a}{$j}{$i}){
                print $f $hash{$a}{$j}{$i},"\t";
            }
            else {
                print $f 0,"\t";
            }
        }
        print $f "\n";
    }

    &call_R_script($a,$title." for ".$a,$xlab." of ".$a,$ylab." of ".$a);
}


sub call_R_script {
    my $out_file = shift;
    my $title = shift;
    my $xlab = shift;
    my $ylab = shift;
    open(RS, ">$out_file.rscript") or die("Cannot write $out_file.rscript");
    print RS qq{
data = read.table("$out_file");
data =t(log(data,2))
pdf("$out_file.pdf");
image((1:nrow(data)), (1:ncol(data)), (as.matrix(data)), col=gray((32:0)/32), ylab="$ylab", xlab="$xlab", main="$title");
dev.off();
    };
    close RS;
    system(qq{Rscript $out_file.rscript});
}
