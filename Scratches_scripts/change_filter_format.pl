#!/usr/bin/perl
# Author: wangyu.big at gmail.com
use warnings;
if (@ARGV<3) {
    die qq{
    Usage:        change_filter_format.pl <IN\-> <# of field each file > <# of file> <black file output>

    Description:  Special for ruanjue's filter format and give pairup of each
    line, attention # of field contain [A]

}
}

select STDERR;
my ($field,$file)  = ($ARGV[1],$ARGV[2]);
print "$field\t$file\n";

# generate index for each file
my @n = qw{0} ;
for my $i(1..$file-1) {
    $n[$i] = $n[$i-1] + $field;
}
print "@n\n";

my %mark;
for my $k (0..25) {
    $mark{$k} = "[".uc(chr(ord('A')+$k))."]";
    print $k,"\t",$mark{$k},"\n";
    
}

#open IN, $ARGV[3];
my $cache = $ARGV[3];
chomp $cache;

select STDOUT;

while(<>){
    chomp;
    #my (@a,@b,@c);
    my @t = split;
    my %hash;
    for my $i (0..($file-1)) {
        last if (not defined $t[$n[$i]]);
        my $tag  = $t[$n[$i]]; # tag of which file

        for my $j (0..($file-1)) { # get which file is right
            if ($tag eq $mark{$j}) {
                for my $k (1..($field-1)) { # push in hash
                    push (@{$hash{$j}},$t[$k+$n[$i]]);
#                    print STDERR "$i\t$j\t$k\n";
                }
                last;
            }
        }
    }
    select STDERR;
#    print join("\t",@{$hash{'1'}});
#    print "\n";
#    print join("\t",@{$hash{'2'}});
#    print "\n";
#    print join("\t",@{$hash{'3'}});
#    print "\n";

    select STDOUT;
    for my $i (0..($file-1)) {
        if (@{$hash{$i}}[0]) {
            print join("\t",@{$hash{$i}});
            print "\t";
        }
        else {
            print $cache;
            print "\t";
        }
    }
    
    print "\n";
}
