use warnings;
use strict;
open IN2, $ARGV[1] || die "perl $0 <MA_file><QV_file>\n";
open IN1,$ARGV[0];
#---- read in ma file 
my %hash;
while(<IN1>){
chomp;
if(/^>/){
	my @array= split/\,/,$_;
#print $array[0];
#print "\n";
	$hash{$array[0]} = 1;
}

}
#---- print qv.file

while(<IN2>){
	chomp;
	if (/^>/){
		if ($hash{$_}){
		print $_;
		print "\n";
		my $line = <IN2>;
		print $line;
		
		}
	
	
	}




}

