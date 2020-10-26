#!/usr/bin/perl
use warnings;
use strict;
#---- version 090320.2.1505
#---- for maq pileup file , count depth bigger than filter count ,count SNP ,count SNP_quality

#---- SUB SECTION                                
sub sub_snp($){  # return pos base depth snp
	my $line = shift;
	chomp $line;
	my @return;
	my @array = split/\s+/,$line;
	 $return[2] = $array[3];
	 $return[1] = $array[2];
	 $return[0] = $array[1];
	 $return[3] = ($array[4]=~ s/[agctAGCT]//isg);
	return @return;
}
#---- get position of each site : input : sequence query
sub sub_rindex($$)   {# return snp POSITION
		my $seq1 =shift;
		my $sub = shift;
		my $i =0;
	    my $cycle_number =length($seq1);
		my @return;
		while(($return[$i]=rindex($seq1,$sub,$cycle_number)) != -1){    # got position of "-" in seq1
		      $cycle_number = $return[$i]-1;
		      $i ++;
		}
       #print "@return\n";
       splice(@return,-1);     # remove last one "-1"
	   return(@return)
}
sub check(\@\@){
	my $input = shift; my @input = @{$input};#print "pos:@input\n";
	my $qua = shift;   my @qua = @{$qua};#print "qua: @qua\n";
	my $sub_depth =0;
	my $filter =8;
	foreach(@input) {
	if (int((ord($qua[$_])-33)/2) >= $filter){$sub_depth ++;
#print "subdepth: $sub_depth\n";
	}
	}
	return ($sub_depth);
}

#----  MAIN    ----

$ARGV[0]|| die "\n\t\tperl $0 <INPUT>\n\n";
my $filter = 8;   # qual - filter
my (%qua,%depth,%snp_qua);                      # total qua  total_depth snp_qua 

while(my $line = <>){
	chomp $line;
#	print $line,"\n";
	my @array = split/\s+/,$line; #chr pos base depth map_base base_qua map_qua
	my @qua = split //,$array[5];
	$array[4] =~ tr/agctn/AGCTN/;

my $depth =0;  						#--- count total base  > filter_qual
foreach(@qua){
	next if(/@/);
	my $cache = int((ord($_)-33)/2);
	if ($cache >= $filter){$depth ++;}
	my $null = exists ($qua{$cache}) ? ($qua{$cache}) ++ : ($qua{$cache} =1);   # total qua
}
my $null = exists ($depth{$depth})? $depth{$depth} ++ : ($depth{$depth} =1); #total depth


	my (%hash,%array);				#---- count snp base ,the second major allen
	my $sec_depth =0;                           # sec_major_all fre , SNP depth
	my	$re_key;
	my @a= sub_rindex($array[4],"A");
	my @c= sub_rindex($array[4],"C");
	my @g= sub_rindex($array[4],"G");
	my @t= sub_rindex($array[4],"T");
	$hash{'a'} = check(@a,@qua);push (@{$array{'a'}},@a); 
	$hash{'g'} = check(@g,@qua);push (@{$array{'g'}},@g); 
	$hash{'c'} = check(@c,@qua);push (@{$array{'c'}},@c); 
	$hash{'t'} = check(@t,@qua);push (@{$array{'t'}},@t); 
	
	foreach my $key(keys %hash){                # return which base is SNP 
        my $null = ($sec_depth<$hash{$key}) ? ($sec_depth = $hash{$key}):'null';
        $re_key = ($null eq "1") ? $key : $re_key;     # SNP base
	}
	foreach(qw(a g c t)){
		my @input =  @{$array{$_}};
		foreach(@input){
		my $cache = int((ord($qua[$_])-33)/2);
		my $null = exists ($snp_qua{$cache}) ? ($snp_qua{$cache}) ++ : ($snp_qua{$cache} =1);   # total qua
#			print "SNP quality:$cache \n";
		} 
	}
	
#----      	print 
=head
	foreach(@qua){
		next if(/@/);
		my $print=int((ord($_)-33)/2);
		print $print," ";
	}
	print "\n";
=cut
if ($sec_depth){
print <<EOF
$array[0]	$array[1]		$depth	$sec_depth	
EOF
}
}
foreach my $key (keys %snp_qua){
	print "SNP_TOTAL_quality\t$key\t$snp_qua{$key}\n";
}
foreach my $key (keys %depth){
print "Depth\t$key\t$depth{$key}\n";
}
foreach my $key (keys %qua){
print "Qua\t$key\t$qua{$key}\n";
}
