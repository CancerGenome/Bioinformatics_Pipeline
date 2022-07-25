#!/usr/bin/perl
# overlap.pl

# id,chr,start,end,strand

use strict;

# options
use Getopt::Std;
use vars qw($opt_x $opt_p $opt_q $opt_m $opt_h);
getopts('x:p:q:m:h');

my $OL=defined $opt_x ? $opt_x : 1; # overlap size cutoff
my $OP=defined $opt_p ? $opt_p : 0; # fraction of block1 overlapped
my $OQ=defined $opt_q ? $opt_q : 0; # fraction of block2 overlapped
my $md=defined $opt_m ? $opt_m : 0; # md: mode
my $help=$opt_h ? 1 : 0;

my $file1=shift;
my $file2=shift;

if ($help || $OP > 100 || $OQ >100) {
	usage(); exit;
}
unless (-e $file1) {
	usage(); exit;
}
unless (-e $file2) {
	usage(); exit;
}

my %dat1;
my %dat2;
read_table($file1,\%dat1);
read_table($file2,\%dat2);

foreach my $refId (sort keys %dat1) {
	next unless defined $dat2{$refId};
	my @blks1=sort {$a->[2] <=> $b->[2]} @{$dat1{$refId}};
	my @blks2=sort {$a->[2] <=> $b->[2]} @{$dat2{$refId}};
	
	my $f=0;
	foreach my $k (0..$#blks1) {
		my $p1=$blks1[$k][2];
		my $p2=$blks1[$k][3];
		my $tmp_f;
		foreach my $j ($f..$#blks2) {
			my $t1=$blks2[$j][2];
			my $t2=$blks2[$j][3];
			if ($t2 >= $p1) {
				$tmp_f=$j;
				last;
			}
		}
		last unless defined $tmp_f;
		$f=$tmp_f;
		
		foreach my $j ($tmp_f..$#blks2) {
			my $t1=$blks2[$j][2];
			my $t2=$blks2[$j][3];
#			next if ($t2 < $p1);
			last if ($t1 > $p2);
			my $os= $p1 < $t1 ? $t1 : $p1;
			my $oe= $p2 < $t2 ? $p2 : $t2;
			my $ol=$oe-$os+1;
			my $op=sprintf "%.2f", $ol/($p2-$p1+1) if ($p2-$p1+1 > 0);
			my $oq=sprintf "%.2f", $ol/($t2-$t1+1) if ($t2-$t1+1 > 0);
			next if ($ol < $OL || $op < $OP || $oq < $OQ);
			my $loc1=join(",",$blks1[$k][1],$blks1[$k][2],$blks1[$k][3],$blks1[$k][4]);
			my $loc2=join(",",$blks2[$j][1],$blks2[$j][2],$blks2[$j][3],$blks2[$j][4]);
			if ($md==0) {
				print join("\t",$blks1[$k][0],$loc1,$blks2[$j][0],$loc2,$ol,$op,$oq),"\n";
			}
			elsif ($md==1) {
				if ($blks1[$k][4] eq $blks2[$j][4]) {
					print join("\t",$blks1[$k][0],$loc1,$blks2[$j][0],$loc2,$ol,$op,$oq),"\n";
				}
			}
			elsif ($md==2) {
				if ($blks1[$k][4] ne $blks2[$j][4]) {
					print join("\t",$blks1[$k][0],$loc1,$blks2[$j][0],$loc2,$ol,$op,$oq),"\n";
				}
			}
		}
	}
	$dat1{$refId}=();
	$dat2{$refId}=();
}
print STDERR "Finish overlap finding between $file1 and $file2\n";

sub read_table{
	my $infile=shift;
	my $dat=shift;
	die "File $infile unavaliale.\n" unless (-e $infile);
	
	open IN, $infile || die $!;
	while (<IN>) {
		chomp;
		my @d=split;
		push @{$dat->{$d[1]}},[$d[0],$d[1],$d[2],$d[3],$d[4]];
	}
	close IN;
	print STDERR "finish loading $infile\n";
}

sub usage{
	my $usage= << "USAGE";
Find overlapped blocks bettween two block sets.
Usage: overlap.pl [options] file1 file2
Options:
  -x <int> minimum overlap length, default=1
  -p <float> 0-1, fraction of block1 overlapped, default=0
  -q <float> 0-1, fraction of block2 overlapped, default=0
  -m <0/1>  m=0: strand free
            m=1: on same strand
            m=2: on oppisite strand
            default=0
  -h        display this help
Author: liqb (BGI.shenzhen)

Please convert your data file into a new format first,
each field delimited by whitespace. The first 5 fields 
should be 'block' id, chromosome id, start postion, 
end position and strand(+/-), like this:
t0000001        chr3    52277392        52277413        -

Please report bugs to <liqb\@genomics.org.cn>
USAGE
	print $usage;
}

