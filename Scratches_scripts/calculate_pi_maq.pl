use warnings;
use strict;
=head
$ARGV[1] || die ("\t\tCalculating maq.snp result and output theta_pi value\n\t\tPerl $0 <In.maq.snp><Window size><Step size>\n\t\t Step default:widonw/10\n");
$ARGV[2] ||  ($ARGV[3] = $ARGV[1]/10);
=cut
my %hash; # store snp exists
#open IN1,"ruf.nt.snpfilter";
open IN, "cache";
my $file = <IN>;
chomp $file;
close IN;
open IN1,$file;
while(<IN1>) {chomp;split;$hash{$_[1]}=1;}#iDprint $_[1];print "\n";}  
close IN1;
#print "INPUT HASH\n";

while(<STDIN>){
	chomp;
	split;  #1_pos 2-base 3-depth 4-align
	next if (not exists $hash{$_[1]});
	my $snp_count = ($_[4] =~ s/[agctAGCT]//isg);
	next if $snp_count ==0;
	$hash{$_[1]}= (($_[3]-$snp_count)*$snp_count)/ ($_[3]*($_[3]-1)/2);
print "$_[1]\t$_[3]\t$snp_count\t$hash{$_[1]}\n";
}
#print "INPUT Alignment\n";
my $window = $ARGV[0];
my $step = $ARGV[1];
my $length = $ARGV[2];
my @point="";
for my $i (0..int($length/($window-$step))){
	 $point[$i]= $i*($window-$step);
}
$point[0]=1;  # not zero
#---- test file
=head
my %hash;
open IN,"ruf.nt.snpfilter";
while(<IN1>) {chomp;split;$hash{$_[1]}=1;}#iDprint $_[1];print "\n";}  
=cut
my @record="";
for my $i (1..$length){
if ($hash{$i}) {
	my $count =0;
	my $array_no = 0 ;
	foreach my $point (@point) {
		next if ($count ==2); 
		if ( (($i-$point)<=$window) && (($i-$point)>0)) {
		$record[$array_no] += $hash{$i};
#		my $aa = int($i/$window);
#print "ipoint:$i\t$point\t$aa\n";
#		print "$record[int($i/$window)]\n";
		$count ++;
		}
		$array_no ++;
	}
}
}
foreach(@record){if($_){}else{$_=0}} # add   zero 
print join("\n",@record);

