#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/VCFstat.pl <Input VCF file> -h -q -g -n -f -e
#        Given a VCF file, count the AC allele counts for each criteria from -g and -q
#        -q: QD score criteria, separate by comma, include lower boundary, default: 0,2,5,10
#        -f: filter out AF >= opt_f, default : 1. be mind AF is inferred from original VCF, and is not changed in current result
#        -g: gnomAD frequency criteria, separate by comman, include upper boundary, default: 0.05, 0.01, 0.001, 0.0001
#            max value from these four: gnomAD_exome_ALL\t%gnomAD_exome_NFE\t%gnomAD_genome_ALL\t%gnomAD_genome_NF
#        -n: default AN number: 125748 *2, the gnomAD exome total number
#        -e: use NFE_AC, not AC, specific for gnomAD VCF, not lab samples
#
#        TODO: use average AN, rather than max AN
#
#        Version Note: V2 add annotation for CADD >= 20, ClinVar P/LP, LOF (At least one should match)
#        design for predicted deleterious variants
#        Add support for both AC or AC_nfe;
#        Add support for removing internal polymorphism filter;
#
#        DESCRIPTION: -h : Display this help
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Sun 12 Jan 2020 11:05:06 AM EST
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
use List::Util qw[min max];

$ARGV[0] || &usage();
our ($opt_h,$opt_g,$opt_q,$opt_n,$opt_f,$opt_e);
getopts("hg:q:n:f:e");

#------- Define Option ----------
my @levelGN; # for Gnomad
my @levelQD; # for QD

if(not defined $opt_n){
	$opt_n = 125748 * 2;
}
if(defined $opt_g){
	@levelGN = split/;/,$opt_g;
}else{
	@levelGN = qw{0.05 0.01 0.001 0.0001};
}
if(not defined $opt_f){
	$opt_f = 1; # used to filter out polymorphism from internal samples
} 

if(defined $opt_q){
	@levelQD = split/;/,$opt_q;
}else{
	@levelQD = qw{0 2 5 10};
}
my $minQD = min(@levelQD);
my $maxGN = max(@levelGN);
#print "QD and GN: $minQD\t$maxGN\n";

#------- Solve Problems ----------
my %hash;
my %max_an; # record max an for each
my %an; # record each an
#my %criteria;

my %hash_lof;
my @LOF = qw{frameshift_deletion frameshift_insertion nonframeshift_insertion nonframeshift_deletion stopgain stoploss splicing "exonic\x3bsplicing"};
#my @LOF = qw{frameshift_deletion frameshift_insertion stopgain stoploss splicing "exonic\x3bsplicing"};
foreach my $lof (@LOF){
	$hash_lof{$lof} = 1;
}

if(defined $opt_e){ # for gnomAD NFE
	open IN, "bcftools query -f '%Gene.refGene\\t%AC_nfe\\t%AN_nfe\\t%QD\\t%gnomAD_exome_ALL\\t%gnomAD_exome_NFE\\t%gnomAD_genome_ALL\\t%gnomAD_genome_NFE\\t%Func.refGene\\t%ExonicFunc.refGene\\t%Func.ensGene\\t%ExonicFunc.ensGene\\t%CLNSIG\\t%CADD_phred\\n' $ARGV[0] |";
}elsif ($opt_n != 125748 * 2){ # for our own samples, because we will define new N
	open IN, "bcftools query -f '%Gene.refGene\\t%AC\\t%AN\\t%QD\\t%gnomAD_exome_ALL\\t%gnomAD_exome_NFE\\t%gnomAD_genome_ALL\\t%gnomAD_genome_NFE\\t%Func.refGene\\t%ExonicFunc.refGene\\t%Func.ensGene\\t%ExonicFunc.ensGene\\t%CLNSIG\\t%CADD_phred\\t%AF\\n' $ARGV[0] |";
}else{ # for gnomAD All
	open IN, "bcftools query -f '%Gene.refGene\\t%AC\\t%AN\\t%QD\\t%gnomAD_exome_ALL\\t%gnomAD_exome_NFE\\t%gnomAD_genome_ALL\\t%gnomAD_genome_NFE\\t%Func.refGene\\t%ExonicFunc.refGene\\t%Func.ensGene\\t%ExonicFunc.ensGene\\t%CLNSIG\\t%CADD_phred\\n' $ARGV[0] |";
}

while(my $line = <IN>){
	chomp $line;
	my ($gene,$ac,$an,$qd,$gn1,$gn2,$gn3,$gn4,$lof1,$lof2,$lof3,$lof4,$clinvar,$cadd,$af) = split/\s+/,$line;
	my $max_gn  = &max_gn($gn1,$gn2,$gn3,$gn4);
	#print $max_gn,"\n";
	next if ($qd < $minQD); # remove those lower than minQD
	next if ($max_gn >= $maxGN); #remove those polymorphism
	if( not defined $af){$af = 0}; # this will happen when using gnomAD result,there is noAF inside
	next if ($af > $opt_f); # by default, $opt_f = 1, this will remove polymorphism from internal controls
	#print STDERR $line,"\n" if ($gene eq "KRT4");
	#print STDERR $line,"\n" if ($gene eq "KRT4");
	my $criteria;

	##### Check LOF, Nonsyn , CADD and ClinVar;
	my $keep_lof = 0 ;
	if(exists $hash_lof{$lof1}){# annotatin from Annovar refseq
		$keep_lof = 1;
	}elsif(exists $hash_lof{$lof2}){# annotation from annovar ensemble
		$keep_lof = 1;
	}elsif(exists $hash_lof{$lof3}){# annotation from annovar refseq splicing
		$keep_lof = 1;
	}elsif(exists $hash_lof{$lof4}){# annotation from annovar ensemble splicing
		$keep_lof = 1;
	}

	my $keep_clinvar = 0; # keep this variant;
	if($clinvar =~/Likely_pathogenic|Pathogenic/){
		$keep_clinvar = 1; 
	}

	my $keep_cadd = 0;
	if($cadd ne "." and $cadd >= 20){
		$keep_cadd = 1;
	}

	next if($keep_lof + $keep_clinvar + $keep_cadd ==0);
#	print $line,"\n";

	# Count the AC for each combination or level
	foreach my $a (@levelQD){
		foreach my $b (@levelGN){
		$criteria = "QD>=".$a."_gnomAD<=".$b;
		#$criteria{$criteria}  = 1;
			if($qd>=$a and $max_gn <= $b){
				#print "Yes: $qd >= $a; $max_gn <= $b\n";
				#print "$hash{$gene}{$criteria}\n";
				if(not exists $hash{$gene}{$criteria} ){
					$hash{$gene}{$criteria} = $ac;
					$max_an{$gene}{$criteria} = $an;
					#push(@{$an{$gene}{$criteria}}, $an); # TO DO, add mean AN here
				}else{
					$hash{$gene}{$criteria} += $ac;
					$max_an{$gene}{$criteria} = max($an, $max_an{$gene}{$criteria});
					#push(@{$an{$gene}{$criteria}}, $an); # TO DO, add mean AN here
				} # end if defined
			} # end $qd and max_gn
		} # end $b for
	} # end $a for
}

### Print Header
my @criteria;
my @header;
foreach my $a (@levelQD){
	foreach my $b (@levelGN){ # TO DO, add mean AN here
	my $criteria = "QD>=".$a."_gnomAD<=".$b;
	my $an = "AN_QD>=".$a."_gnomAD<=".$b;
	push(@header, $criteria);
	push(@criteria, $criteria);
	push(@header, $an);
	}
}
print "Gene\t",join("\t",@header),"\n";

### Print each count
foreach my $key (keys %hash){
	print "$key\t";
	foreach my $keys (@criteria){
		if (exists $hash{$key}{$keys}){
			print $hash{$key}{$keys},"\t"; # TO DO, add mean AN here
			print $max_an{$key}{$keys},"\t";
		}else{
			print "0\t";
			print "$opt_n\t";
		}
	} # end for2
	print "\n";
}

sub max_gn(){
	my @Z = @_;
	my $max = 0;
	foreach my $z (@Z){
		next if ($z eq ".");
		if($max <$z){
			$max = $z;
		}
	}
	return ($max);
}

