#!/usr/bin/perl 
my @all_file = `ls raw/*.raw`;
my $num =60;

foreach my $file (@all_file){
	chomp $file;
	$line= <$file>;
	chomp $line;
	print ">$file\n";
	foreach my $i (1..int(length($line)/60)+1){
	print substr($line,$i*60-59,$i*60),"\n";
	}
}
