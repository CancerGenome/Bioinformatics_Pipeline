#!/usr/bin/perl
# change the vcf format to impute format

##### Usage Example ##########
#./vcf2gene.pl -v vcf_file 
##############################

use strict;
use warnings;
use Getopt::Std;
use Compress::Zlib;

&main(@ARGV);
exit;

sub main
{
	getopts("hgv:", \ my %opts);
	if(exists $opts{h}) 
	{
		print "The code is to used to convert the VCF to Genotype data format.\n";
		print "===============================================================\n";
		print "\nOptions:\n\n";
		print "-v vcf_file\n";
		print "-g \n\n";
		print "===============================================================\n";
		print "Jason Liu (C) 2010\n";
	}else{
		my $file = $opts{v};
		&read_vcf($file, $opts{g});
	}
}

sub read_vcf
{
	my $file = shift;
	my $g = shift;
	my $gz = gzopen($file, "rb") || die "Can't open $file:$!";
	
	my $p = &q2p;
	my $count = 0;
	while($gz->gzreadline($_))
	{
		$count++;
		#warn "$count lines processed.\n" if ($count % 100000 == 0);
		next if(/#/);
		my @line = /(\S+)/g;

		my $chr       = $line[0];
		my $pos       = $line[1];
		my $id        = $line[2];
		$id           = "---" if($id eq ".");
		my $allele_A  = $line[3];
		my $allele_B  = $line[4];
		my @header = ($chr, $id, $pos, $allele_A, $allele_B);

		 my $gl_idx = -1;
                my @formats = split /:/, $line[8];
                for(my $i = 0; $i < @formats; $i++)
                {
			if (defined $g) {
				$gl_idx = $i if ($formats[$i] eq "GT");
			} else {
                        	$gl_idx = $i if ($formats[$i] eq "GL" | $formats[$i] eq "PL");
			}
                }
		my @indvs = @line[9..$#line];
		my $gps;
		if (defined $g) {
                	die "GT is missing in VCF format.\n" if($gl_idx == -1);
			$gps = &gt4indv(\@indvs, $gl_idx, $formats[$gl_idx]);
		} else {
                	die "Either GL or PL is missing in VCF format.\n" if($gl_idx == -1);
			$gps = &gp4indv(\@indvs, $gl_idx, $formats[$gl_idx], $p);
		}
		&print_line(\@header, $gps);
	}
        
        $gz->gzclose();
}


# convert to genotype probability for each individual
sub gp4indv
{
	my $indvs = shift;
	my $gl_idx = shift;
	my $format = shift;
	my $p = shift;
	my @gps;	

	foreach my $indv (@{$indvs})
	{
		my $gp;
		if($indv ne "./.")
		{
			my @format = split /:/, $indv;
			my $gls = $format[$gl_idx]; 
			my $gl;
			if ($gls =~ /,/) {
				$gl = [split /,/, $gls];
			} else {
				$gl = [0, 0, 0];
			}
		
			$gp = &gl2gp($gl) if ($format eq "GL");
			$gp = &pl2gp($gl, $p) if ($format eq "PL");
		}else{
			$gp = [1/3, 1/3, 1/3];
		} 		
		push @gps, $gp;
	}

	return \@gps;
	
}

sub gt4indv
{
	my $indvs = shift;
	my $gl_idx = shift;
	my $format = shift;
	my @gps;	

	foreach my $indv (@{$indvs})
	{
		my $gp;
		if($indv ne "./.")
		{
			my @format = split /:/, $indv;
			my $gt = $format[$gl_idx]; 
			$gp = &gt2gp($gt) if ($format eq "GT");
		}else{
			$gp = [1/3, 1/3, 1/3];
		} 		
		push @gps, $gp;
	}

	return \@gps;
}

# convert to genotype likelihood to genotype probability
sub gl2gp
{
	my $gl = shift;
	my @gp;

	my $sum = 0;
	for(my $i = 0; $i < 3; $i++)
	{
		push @gp, 10 ** $gl->[$i];
		$sum += 10 ** $gl->[$i];
	}

	for(my $i = 0; $i < 3; $i++)
	{
		$gp[$i] /= $sum;
	}

	return \@gp
}

# convert to Phred score likelihood ato genotype probability
sub pl2gp
{
	my $pl = shift;
	my $p = shift;
	my @gp;

	my $sum = 0;
	for(my $i = 0; $i < 3; $i++)
	{
		push @gp, $p->[$pl->[$i]];
		$sum += $p->[$pl->[$i]];
	}
	$gp[$_] /= $sum foreach (0..2);

	return \@gp
}

# convert to genotype probabilities according to genotypes
sub gt2gp
{
	my $gt = shift;
	my @gp = (0, 0, 0);
	my @alleles = split /\/|\|/, $gt;
	my $sum = $alleles[0] + $alleles[1];
	$gp[0] = 1 if ($sum == 0);
	$gp[1] = 1 if ($sum == 1);
	$gp[2] = 1 if ($sum == 2);
	
	return \@gp;
}

sub q2p
{
	my @p = ();
	push @p, 10 ** (-$_/10) foreach (0..255);
	return \@p;
}

sub print_line
{
	my $header = shift;
	my $gps   = shift;

	#print "@{$header} ";
	printf "%d %s %d %s %s ", $header->[0], $header->[1], $header->[2], $header->[3], $header->[4];
	for(my $i = 0; $i < @$gps; $i++)
	{
		#print "@{$gps->[$i]} ";
		for(my $j = 0; $j < @{$gps->[$i]}; $j++)
		{
			printf "%1.4f ", $gps->[$i]->[$j];
		} 
	}
	printf "\n";
}
