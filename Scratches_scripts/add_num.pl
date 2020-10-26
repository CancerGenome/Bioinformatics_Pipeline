use warnings;
use strict;

for my $i (2..3) {
open IN, "jap$i\_qv";
while(<IN>){
chomp;
if (/^>/){
my @array = split/[\>,\_]/,$_;
$array[1] += ($i*3000-3000);
shift(@array);
print ">",join ("_",@array);
print "\n";
}
else {print;print"\n";}
}
close IN;
}
