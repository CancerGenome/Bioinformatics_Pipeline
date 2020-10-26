use warnings;
use strict;
$ARGV[0] || die "perl $0 <INPUT>\n";
my $tag =0;
while(<>){
chomp;
if (/^>/){
$_ =~ s/>//;
if (/F3_1/) {$_ =~ s/F3_1/F3/;$tag =0;}
if (/F3_2/) {$_ =~ s/F3_2/F3/;$tag =1;}
if (/F3_3/) {$_ =~ s/F3_3/F3/;$tag =2;}

my @array = split /\_/,$_;
#print $array[0];
#print "\n";
 $array[0] += (3000*$tag);
 $tag =0; 
#print $array[0];
#print "\n";
print ">";
print join("_",@array);
}
else {print;}
print "\n";

}

