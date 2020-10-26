use warnings;
use strict;

$ARGV[0] || die "perl $0 <input>, replacing _F3_1 to _F3 ect\n\n ";
$ARGV[1] || ($ARGV[1]=1);
open IN, "$ARGV[0]";
while(<IN>){
chomp;
if (/^>/){
$_ =~ s/_$ARGV[1]$//;
print;
print "\n";
}
else {print;print "\n";}
}
