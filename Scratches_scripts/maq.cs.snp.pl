use warnings;
#use strict;
$ARGV[0] || die ("perl $0 <input>");
my $last_pos=0;
my $last_lin="";
my ($a,$b,$c,$d)= "A";  # means  a_last_ref c_last_cs_change b_now_ref d_now_cs_change
while(<>){
chomp;
split;
$b = $_[2];$d = $_[3];
if(($_[1]-$last_pos==1)&& ((($a eq $b)&&($c eq $d)&&($a ne $d))  ||  (($b eq $c) &&($a eq $d))  ||  (($a ne $b)&&($a ne $c)&&($a ne $d)&&($b ne$c)&&($b ne $d)&&($c ne $d) ) )){
print $last_lin;
print "\n";
print $_;
print "\n";
}
$last_pos = $_[1];
$a= $b; $c= $d;
$last_lin = $_;
}
