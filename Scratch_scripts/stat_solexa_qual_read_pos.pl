#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@gmail.com>, Wang Yu <wangyu.big@gmail.com>
#Update: 2009-11-12
#Update: 2010-01-07  fix loop bug 
#Update: 2010-12-28  by wangy, add solid function
#Copyright: BIG
#
use strict;

my $in_file  = shift or &usage;
my $out_file = shift or &usage;
my $state = shift || 0;
my $title    = shift || "Quality distribution for $in_file";

my @pos_qs = ();
my $q_start = ord("A");
my $q_end   = $q_start + 40;

open(IN, $in_file) or die("Cannot open $in_file");

while(<IN>){
    $_ = <IN>;
    <IN> unless $state;
    $_ = <IN> unless $state;
    chomp;
    if ($state == 0) {
        for(my $i=0;$i<length($_);$i++){
            $pos_qs[$i][ord(substr($_, $i, 1))]++;
        }
    }
    elsif ($state == 1) {
        my @c = split/\s+/;
        for(my $i=0;$i<=$#c;$i++){
            $c[$i] = 0 if ($c[$i] < 0 );
            $c[$i] += $q_start;
            $pos_qs[$i][$c[$i]]++;
        }
    }
}

close IN;

open(OUT, ">$out_file.qual_stat") or die("Cannot write $out_file.q_stat");

for(my $i=0;$i<200;$i++){
    my $qs = $pos_qs[$i];
    last unless($qs);
    my $sum = 1;
    for(my $j=$q_start;$j<$q_end;$j++){$qs->[$j] = 0 unless(defined $qs->[$j]); $sum += $qs->[$j]; }#sum
    for(my $j=$q_start;$j<$q_end;$j++){
        my $r = int(100 * $qs->[$j] / $sum);
        print OUT "$r";
        print OUT "\t" if($j);
    }
    print OUT "\n";
}

close OUT;

&call_R_script($out_file, $title);

1;

sub usage {
    print "Usgae: $0 <fastq_file> <output_png> <0/1 model,solexa or solid qual file> [<Title>:\"Quality distribution for <fastq_file>\"]\n";
    exit;
}

sub call_R_script {
    my $out_file = shift;
    my $title = shift;
    open(RS, ">$out_file.rscript") or die("Cannot write $out_file.rscript");
    print RS qq{
data = read.table("$out_file.qual_stat");
png("$out_file");
image((1:nrow(data)), (1:ncol(data)), (as.matrix(data)), col=gray((32:0)/32), ylab="Quality value", xlab="Position of read", main="$title");
dev.off();
    };
    close RS;
    system(qq{Rscript $out_file.rscript});
}
