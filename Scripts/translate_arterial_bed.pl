#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:/home/yulywang/bin/translate_arterial_bed.pl  -h
#        DESCRIPTION: -h : Display this help
#        Input all arterial beds details, separate by ; if they are from diff columns of origianl file
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Fri 13 Sep 2019 05:18:24 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my %hash;
my @SubTissue;
my @Tissue;

sub uniq{
    my %seen;
    grep !$seen{$_}++, @_;
}

while(my $line = <DATA>){ # prepare subtissue and tissue
	chomp $line;
	$line = lc $line;
	my @F = split/\s+/,$line;
	my $tissue = $F[0];
	push(@Tissue, $tissue);
	@F = uniq(@F[1..$#F]);
	for my $i(0..$#F){
		push(@{$hash{$F[$i]}}, $tissue); # one key may have different value
		push(@SubTissue, $F[$i]);
	}
}

@SubTissue = uniq(@SubTissue);
@Tissue = uniq(@Tissue);
print join("\t",@Tissue),"\tOriginal\n";
#print join("\n",@SubTissue),"\n";

while(my $line = <>){
	chomp $line;
	my @F = split/\;/,$line;
	my %count; # count SubTissue tissue
	foreach my $f (@F){
		$f = lc $f;
		$f =~ s/[-\)\()\_\/\?]/ /g;
		#print "Original\t$f\n";
		#print "$f";

		foreach my $sub_tissue (@SubTissue){
			if($f =~ /\b$sub_tissue\b/i){ # only word match
				#print "\tmatch_keyword\t",$sub_tissue,"\n";

				my @Tissue = @{$hash{$sub_tissue}};
				# print SubTissue tissue contains sub tissues
				foreach my $tissue (@Tissue){ # is_a mean a root of 
					#print "\t\tis_a\t$tissue\n";
					$count{$tissue} =1 ;
				} # end for
			} # end if
		} # end SubTissue keyword
	
	}

	foreach my $key (@Tissue){
		if(exists $count{$key}){
			print $count{$key},"\t";
		}else{
			print "0\t";
		}
		#print "\tTissue","\t",$key,"\t",$count{$key},"\n";
	} # end for each 
	print "$line\n";
}

__DATA__
Aorta Aorta TAA Isolated Ascending Aorta TDA aortic arch AAA
cerebral PCA PCOMM PCA PCOMM ACA ACA ACOMM Basilar MCA MCA cerebral intracranial OPTHALMIC eye pcom eyes
cervical ECA ECA ICA ICA VA VA CCA CCA no_intracranial ICA/VA no_cerebral_ICA/VA VERT VERTEBRAL LICA RICA
Coronary Coronary LAD RCA LCX Diagonal non-LAD Circumflex PDA circumflx SCAD OM OM2
ica ICA ICA LICA RICA
visceral.other Splenic Hepatic Pancreatic  Duodenal Gastric HA
le ILIAC ILLIAC CIA CIA EIA EIA  IIA IIA CFA CFA DFA DFA SFA SFA Pop Pop Tibio-Peroneal Trunk Tibio-Peroneal Trunk ATA ATA PTA PTA Peroneal Peroneal DPA DPA FEMORAL
mesenteric celiac SMA mesenteric
renal MRA MRA RAA RAA Renal RA
ue sub sub Axillary Axillary Brachial Brachial Ulnar Ulnar
va VA VA VERT VERTEBRAL
visceral.All Celiac SMA MRA MRA RAA RAA IMA Splenic Hepatic Pancreatic  Duodenal Gastric mesenteric renal RA HA
