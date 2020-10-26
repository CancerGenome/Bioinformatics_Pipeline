#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./pileup_bwa_inf.pl 
#
#  DESCRIPTION:  Get information from bwa pileup file and filter low quality(8) 
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/30/2009 04:51:51 PM
#      Version:  1.0
#===============================================================================

		  )
}
use strict;
use warnings;

if ($ARGV[0] eq "help" || $ARGV[0] eq "-h" || $ARGV[0] eq "-help"){
	&usage();
}
#open INDEL, ">indel";
#open ABNORMAL, ">abnormal.sam";
while(<>){
	chomp;
	split; # chr pos ref consen consen_quality snp_quality max_map_quality seq seq_quality
	if ($_[2] eq "*") {
		#print INDEL "$_\n";
		next;}   # omit indel line
	my ($chr,$pos,$ref,$cons,$cons_q,$snp_q,$max_map_q,$dep_old,$seq,$qua) = @_;


#------ remove others
	$seq =~ s/[+-][0-9]+[ACGTNacgtn]+//isg;   # omit indel
	$seq =~ s/(\^\S)|\$//isg;   # omit  ^\S map quality
	if (length($seq) != length($qua)) {
#		print ABNORMAL length($seq),"\t",length($qua),"\t$seq\t$qua\t$_\n";
#next;
	}
#	print join("\t",@{$a}),"\t\t$pos\t$dep_old\t$seq\t$qua\t","\n";
#	print length(join("",@{$b})),"\t",$dep_old,"\t",join("",@{$b}),"\t$qua","\n";
	my ($new_seq,$new_qua,$ave_qua)= &filter_quality($seq,$qua);
next if (not defined $ave_qua );
	$new_seq = join ("",@{$new_seq});   # covert reference to array
	$new_qua = join ("",@{$new_qua});
#	print "$new_seq\t$new_qua\n";
#my @c = acgt($new_seq);
	my @c = &acgt($new_seq);
	print "$chr\t$pos\t$ref\t",length($new_seq),"\t$ave_qua\t",join ("\t",@c),"\n";
}




#------- SUB -------


sub filter_quality($$){
	my $a = shift; # seq input
	my $q = shift; # filter 
	my @a = split//,$a;
	my @q = split//,$q;
	my (@new_a,@new_q);
	my $ave_quality;
	for my $i (0..$#a){
		if (ord($q[$i])-64>=3){
		push (@new_a,$a[$i]);
		push (@new_q,$q[$i]);
		$ave_quality += (ord($q[$i])-64);  # mark 64 for solexa
		}
	}
#if ($ave_quality==0 || $ave_quality eq ""){return 0}
	if (not defined $new_a[0]){return 0}
	else{
		$ave_quality=int($ave_quality/($#new_a+1));
		return(\@new_a,\@new_q,$ave_quality);}
}

sub acgt($){  # return a c g t forward backward count
$_ = shift;
	my @b = split//,$_;
	my @a;
	$a[0] = grep /A/i,@b;  # i means ignore A/a
	$a[1] = grep /C/i,@b;
	$a[2] = grep /G/i,@b;
	$a[3] = grep /T/i,@b;
	$a[4] = grep /A|G|C|T|\./,@b;
	$a[5] = grep /a|g|c|t|\,/,@b;
	return (@a);
}

