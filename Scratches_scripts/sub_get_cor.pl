my (@array_depth,@array_major,@array_minor,@min); 
my ($depth,$major_base,$major_freq,$minor_base,$minor_freq,$pos,$forward_depth,$backward_depth,$minor_forward_depth,$minor_backward_depth,$minor_quality,$minor_depth);
# see annotation and must defined these variance


while(<>){
	chomp;
	next if(/#/);
cor_split($_);
print "$pos\t$depth\t$minor_freq\n";
}

#----sub
sub cor_split(){
my $line = shift;
chomp $line;
@_ = split /\s+/,$line;
		$pos = $_[1];
	if($_[3] eq "/0:0"){next;}
	 @array_depth = split /[\/,\:]/ ,$_[3];
		$depth = $array_depth[0];$forward_depth= $array_depth[1];$backward_depth=$array_depth[2];
     @array_major = split/\:/,$_[4];
	 	$major_base = $array_major[0];$major_freq= $array_major[1];
     @array_minor = split/\:/,$_[5];  
	 	$minor_base = $array_minor[0];$minor_freq= $array_minor[1];
		my %pos = (
		A => 6,
		C => 7,
		T => 8,
		G => 9
		);
		@min = split/[\/,\(,\)]/,$_[$pos{$minor[$pos]}];
		$minor_depth = $min[0];$minor_forward_depth= $min[1];$minor_backward_depth= $min[2];$minor_quality= $min[3];
}
