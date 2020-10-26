#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/translate_FMD_chipID.pl  -h
#        DESCRIPTION: -h : Display this help
#        -p: print all oldID and cleanID as a STDERR
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 07 Nov 2019 11:12:24 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_p);
getopts("hp");
my %hash;

while(my $line = <DATA>){
	chomp $line;
	my @F = split/\s+/,$line;
	my $ID = $F[0];
	my $old_ID = $ID;
	if ($ID =~ /^ADC/){
		$ID =~ s/ADC/ADC-/;
	}elsif ($ID =~ /^AD/){
		$ID =~ s/AD/AD-/;
	}
	my @G = split/\-/, $ID;
	my $clean_ID;
	if($#G == 0){
		$clean_ID =  $G[0];
	}else{
		my @H = split//,$G[1];
		while($#H < 3){
			unshift(@H, 0);
		}
		$clean_ID = $G[0]."-".join("",@H);
	}

	if(defined $opt_p){
		print STDERR "$old_ID\t$clean_ID\n";
	}
	$hash{$old_ID} = $clean_ID;
}

while(my $line = <>){
	chomp $line;
	my @F = split/\s+/,$line;
	if(exists $hash{$F[0]}){
		print $line,"\t",$hash{$F[0]},"\n"
	}else{
		print $line,"\t-\n"
	}
}
#DATA Frome,"/home/yulywang/FMD/GWAS_genotype/Merge_248_294_325_333/plink.fam";
__DATA__
AD109
AD109
AD122
AD122
AD16
AD16
AD17
AD212
AD212
AD225
AD225
AD225
AD225
AD236
AD236
AD236
AD244
AD244
AD25
AD272
AD272
AD272
AD272
AD273
AD273
AD284
AD295
AD295
AD298
AD298
AD298
AD302
AD302
AD312
AD320
AD332
AD333
AD335
AD338
AD339
AD374
AD375
AD406
AD421
AD421
AD424
AD424
AD424
AD432
AD432
AD443
AD486
ADC5001
ADC5021
AD595
AD595
AD614
AD614
AD614
AD625
AD627
AD680
AD680
AD691
AD691
AD691
AD701
AD701
AD701
AD730
AD730
AD759
AD759
ADC9001
ADC9001
ADC9001
ADC9002
ADC9003
ADC9004
ADC9006
ADC9007
ADC9011
ADC9011
ADC9012
ADC9012
ADC9012
