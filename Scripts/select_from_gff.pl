#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./select_from_gff.pl   <Query list>
#
#  DESCRIPTION:  Given chromosome site and output gff file , input chromosome must sort as chr1 chr2 chr3...
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  12/23/2009 
#===============================================================================

		  )
}
use strict;
use warnings;
$ARGV[0]|| &usage();

my %chr;
my ($f, $r,$r_chr);
my (@f, @r);

for my $i(1..22){
	$chr{$i} = "chr".$i;	
	$chr{"chr".$i} = $i;	
}
$chr{23} = "chrX";
$chr{"chrX"} = 23;
$chr{24} = "chrY";
$chr{"chrY"} = 24;
$chr{25} = "chrM";
$chr{"chrM"} = 25;

chdir("/share/disk6-4/wuzhy/wangy/cancer/cancer_gff/link");
my @file = <*.annotate>;
#my @file = <BIG_S069_20090508_1_nor_F3.unique.csfasta.ma.35.3_qv.gff.annotate>;
chomp @file;
#print @file;

my $tag=0;
foreach my $file(@file){
$tag ++;	
print STDERR "$tag $file\n";
open F,$ARGV[0];
open R,$file;
my $cache ;
	while(<R>){
	if(/^#/){$cache = tell R; next;}
#	print "Befor $_\n";
	seek (R,$cache,0);
	last;
}
&read_r();
#print "BEFORE",join("\t",@r),"\n";
&read_f();
     while(1){
		 if ($f[0] == $r_chr){
		 	if ($f[1] < $r[3]){
				&read_f();
				last unless (defined $f);
			}
			elsif ($f[1] > $r[4]){
				&read_r();
				last unless (defined $r);
			}
			elsif($f[1] <= $r[4] && $f[1]>= $r[3]){
				print "$f[0]\t$f[1]\t$tag\t$r","\n";
#j				&read_f();
#				last unless (defined $f);
				&read_r();
				last unless (defined $r);
			}
		 }
			elsif ($f[0]< $r_chr){
				&read_f();
				last unless (defined $f);
			}
			elsif ($f[0] > $r_chr){
				&read_r();
				last unless (defined $r);
			}
	 }	
}

sub read_f(){
	$f = <F>;
	last unless (defined $f);
	chomp $f;
#	print $f,"\n";
	@f = split /\s+/,$f;
	$f[0] = $chr{$f[0]};
}
sub read_r(){
	$r =<R>;
	chomp $r;
#	print $r,"\n";
	@r = split /\s+/,$r;
	if ($r=~ /i=(\d+);/){$r_chr = $1;}
}
