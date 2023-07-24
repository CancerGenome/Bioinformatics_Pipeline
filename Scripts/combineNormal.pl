#!/usr/bin/perl
my %hash;
open IN,"$ARGV[0]";

while(<IN>) {
    chomp;
    split;
    $hash{$_[0]}{$_[1]}{$_[2]} = "$_[3]\t$_[4]\t$_[5]\t$_[6]";
}
close IN;

#my @a = <DATA>;
my @a = `cut -f1 $ARGV[0] | sort -u`;
my @b = `cut -f2-3 $ARGV[0] | msort -kb1,n2 | uniq `;
#print @a;
#print @b;
chomp (@a,@b);
print "Chr\tPos\t";
print join ("\t\t\t",@a),"\n";

foreach my $b(@b) {
    chomp $b;
    @_ = split/\s+/,$b;
    print "$_[0]\t$_[1]\t";
    foreach my $a(@a) {
        if ($hash{$a}{$_[0]}{$_[1]}) {
            print $hash{$a}{$_[0]}{$_[1]},"\t";
        }
        else {
            print "0\t0\t0\t0\t";
        }
    }
    print "\n";
}

__DATA__
HCC1-N0
HCC1-N1
HCC2-N1
HCC3-N1
HCC4-N1
HCC6-N1
HCC7-N1
HCC8-N1
HCC9-N1
HCC10-N4
HCC11-N0
HCC12-N1
HCC13-N0
