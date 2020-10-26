#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./fix_bwa_bug_and_split.pl  <Prefix of file>
#
#  DESCRIPTION:  fix bwa 5.5 115 and 179 tag bug and translate its seq and complete its quality file 
#			Use standin as input, so pipe is preferred.			
#			Its output divided as chromosome and uniq and mate_pair			
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  02/02/2010 
#===============================================================================

		  )
}
use strict;
use warnings;
use FileHandle;
$ARGV[0] ||&usage();

#---- Created File handle
my %handleu;
my %handlep;
my @name;
	while(my $line=<DATA>){
		chomp $line;
		my @a = split/\s+/,$line;
#		print @a;
		push (@name,@a);
	}
	
	foreach my $n(@name){
		my $uniq = $ARGV[0].".$n.uniq";
		my $pair = $ARGV[0].".$n.mate";
		my $fhu = FileHandle->new(">$uniq");
		my $fhp = FileHandle->new(">$pair");
		$handleu{$n} = $fhu;
		$handlep{$n} = $fhp;

	}

while(<STDIN>){
	chomp;
	my @a = split;
	next if ($#a<=11);
		#---- fix untrslate bug of reverse mapping
	if ($a[1]==153 ||$a[1]== 89 ||$a[1]== 113 ||$a[1]== 177 ||$a[1]== 115 ||$a[1]== 179 ||$a[1]== 145 ||$a[1]== 147 ||$a[1]== 81 ||$a[1]== 83){
#		print $a[9],"\n";
		$a[9] =~ tr/[ACGT]/[TGCA]/;
#		print $a[9],"\n";
	}

	if (length($a[10])!= length($a[9])){
		if ($a[10]=~/XT:A:|XC:i/){
			$a[10] = "!" x length($a[9])."\t$a[10]";
		}
		else {
		    $a[10] = "!" x length($a[9]);
		}
#			print $a[10],"\n";
	}

	my $handle_uniq = $handleu{$a[2]};
	my $handle_mate = $handlep{$a[2]};

	if (/XT:A:U/){print $handle_uniq join ("\t",@a),"\n";}
	if ($a[1] == 67|| $a[1]==131 || $a[1]==115|| $a[1]==179) {print $handle_mate join ("\t",@a),"\n";}
	

}

__DATA__
chr10
chr11
chr12
chr13
chr14
chr15
chr16
chr17
chr18
chr19
chr1
chr20
chr21
chr22
chr2
chr3
chr4
chr5
chr6
chr7
chr8
chr9
chrM
chrX
chrY
