use warnings; 
use strict;
open IN1, "1.pileup";
open IN2, "2.pileup";
open IN3, "3.pileup";
open IN4, "4.pileup";
my ($a,$g,$c,$t);
while(my $line1=<IN1>){
      chomp $line1;
      my @array = split,$line1;  #0_name 1_pos  2_ref  3_dep  4_mismatch
	  my $pos = $array[1];
	  my $ref = $array[2];
	  my $dep = $array[3];
	  $a=$g=$c=$t=0;
      if ($array[4] ne @){
		  sta($array[4])}
#	  printf  <<EOF
#$pos	$ref	$dep	$a	$g	$c	$t
#EOF


}


sub sta {
	my $now = shift;
	$now =~ tr/AGCT/agct/;
	my $as= ($now =~ s/a//isg);	
	my $cs= ($now =~ s/c//isg);	
	my $gs= ($now =~ s/g//isg);	
	my $ts= ($now =~ s/t//isg);	
	$a += $as;
	$c += $cs;
	$g += $gs;
	$t += $ts;
}

