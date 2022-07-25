#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Prepare_SignificantGeneInfo.pl  -h -f -r
#        DESCRIPTION: -h : Display this help
#        -f: prefix of the file [default: adult_matchPC]
#        -r: ratio = # of ctrl/ # of case
#        -c: which column of input file is gene name, start from 1. 
#
#        By default  the input file format is from SignificantGene.Output:
#			SI	Category	Test	GT	Genome_Wide	ST	Syn_Wide
#			SI	Deleterious	Collapse	3.78e-06	-	0.00895	-
#		You can change the preferred column with -c
#
#        The truth is any of them match, then define ctrl>case
#        Carefully examin those case of ctrl>case and try to save any genes.
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Thu 04 Jun 2020 04:28:49 PM EDT
#        Note: update the logic for ctrl and case, now will output case>ctrl, 
#        if any matching the criteria
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_f,$opt_r,$opt_c);
getopts("hf:r:c:");
if(not defined $opt_f){
	$opt_f = "adult_matchPC";
}
if(not defined $opt_r){
	$opt_r = 1;
}

my %gene; # record each gene category
# If not defined opt_c, will read the format of SignificantGene.Output
if( not defined $opt_c){
	while (my $line = <>){
		chomp $line;
		my @F = split/\s+/,$line;
		# add both syn and genome wide result together
		$F[$#F] = $F[4].",".$F[$#F]; # both syn variants and genome wide significant variants included
		next if($F[$#F] eq "-,-");
		my @G = split/,/,$F[$#F];
		foreach my $g (@G){
			$gene{$g} .= $F[1].",";  # which category is significant
			#print "$g\t",$gene{$g},"\n";
		}
	}
}

# if defined opt_c, will only read this column
if(defined $opt_c){
	$opt_c--; 
	while (my $line = <>){
		chomp $line;
		my @F = split/\s+/,$line;
		$gene{$F[$opt_c]} = "Deleterious,LOF_0.01,LOF_0.05,LOF_Nonsyn_0.01,LOF_Nonsyn_0.05";
	}
}

# get the record from del and trad analysis result
my $del = "../Deleterious/".$opt_f.".burden.allfisher.forexcel";
my $trad = "../All/".$opt_f.".burden.forexcel";

my %del;
my %trad;

open IN1, $del;
while (my $line = <IN1>){
    chomp $line;
    my @F = split/\s+/,$line;
	if(exists $gene{$F[0]}){
		$del{$F[0]} = $line;
	}
}
close IN1;

open IN2, $trad;
while (my $line = <IN2>){
    chomp $line;
    my @F = split/\s+/,$line;
	if(exists $gene{$F[0]}){
		$trad{$F[0]} = $line;
	}
}
close IN2;

##### judge which one failed enriched on case side
my $ratio = $opt_r; # ratio between case and control
foreach my $key(keys %gene){
	my $value = $gene{$key};
	next if ($value eq "Category,");
	my $del_line = "-\t"x20;
	my $trad_line = "-\t"x44;
	$del_line .= "-";
	$trad_line .= "-";

	if(exists $trad{$key}){
		$trad_line = $trad{$key};
	}
	if(exists $del{$key}){
		$del_line = $del{$key};
	}

	my @V = split/\,/,$value;
	my @D = split/\s+/, $del_line;
#	print $del_line,"\n";
	my @T = split/\s+/,$trad_line;

	my $status = "Case>Ctrl"; # means case has higher number than control
	foreach my $v(@V){
		if($v eq "Deleterious" and ($D[$#D-1] * $ratio < $D[$#D]) ){
			$status = "Ctrl>Case";	
		}elsif($v eq "LOF_0.01" and ($T[$#T-7] * $ratio < $T[$#T-6])){
			$status = "Ctrl>Case";	
		}elsif($v eq "LOF_0.05" and ($T[$#T-5] * $ratio < $T[$#T-4])){
			$status = "Ctrl>Case";	
		}elsif($v eq "LOF_Nonsyn_0.01" and ($T[$#T-3] * $ratio < $T[$#T-2])){
			$status = "Ctrl>Case";	
		}elsif($v eq "LOF_Nonsyn_0.05" and ($T[$#T-1] * $ratio < $T[$#T])){
			$status = "Ctrl>Case";	
		}				
	}

	print $gene{$key},"\t",$status,"\t",$del_line,"\t",$trad_line,"\n";
}
