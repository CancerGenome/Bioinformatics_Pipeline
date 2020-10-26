use warnings;
use strict;

my @file = `ls *_qv`;
#my @file = `ls test.qv`;

foreach my $file (@file) {	
	chomp $file;
	open IN, $file;
	my %hash;
		while(<IN>){
		next if (/>/);
		next if (/#/);
		chomp;
		split;
		foreach(@_){
		my $null  = (exists $hash{$_})?$hash{$_}++:($hash{$_}=1);
		}
		}
		foreach my $key(keys %hash){
		print  "$file\t$key\t$hash{$key}\n";
		}
#		close IN;
}
