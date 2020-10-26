#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Collapse_Pos.pl  -h
#        DESCRIPTION: -h : Display this help
#        
#        -s: sample column start, default 111 (this is the format after call_header3), 
#            all column after this number will be samples, no other information
#
#        Design for pull down the detailed gene information for FMD
#
#	     Version Chip, will not output any related information, delete All DATA, need to full fill this information
#        Version 2, will only process multiple sample at one line
#            191206: update to avoid duplication samples, double counting 
#        Version 1, will only process one sample at one line
#        Dir: ~/FMD/anno/TLN1
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 03 Jun 2019 03:18:40 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_p,$opt_s);
getopts("hs:");
my $sam_start = 111;
if(defined $opt_s){
	$sam_start = $opt_s - 1;
}
#print "$pos_col\t$sam_col\n";

# Store all sample infor as HASH
my %id;
my %gender;
my %age;
my %role;
my %relative;
while(my $line = <DATA>){
	my @F = split/\s+/,$line;
	$gender{$F[0]} = $F[1];
	$id{$F[0]} = $F[2];
	$age{$F[0]} = $F[3];
	$role{$F[0]} = $F[4];
	$relative{$F[0]} = $F[5];
}

my $line = <>;
chomp $line;
print $line,"\tSample_All\tPed\tCase\tCtrl\tOther\n";
my $ped = 0 ;
my $ad = 0 ;
my $ctrl = 0 ;
my $other = 0 ;

while(my $line = <>){
	my @F = split/\s+/,$line;
	print join("\t",@F[0..($sam_start-1)]),"\t";
	#print $F[$sam_col],"\t",$sam_col,"\n";

	my %sample; # record the sample_num to avoid duplications; 191206 update
    for my $i ($sam_start..$#F){
		my @G = split/\=/,$F[$i];
		next if $G[1] eq "0/0";
		next if $G[1] eq "./.";
		#next if (exists $sample{$id{$G[0]}}); 
		#$sample{$id{$G[0]}} = 1; # record sample name, avoid duplication; 191206 update
		#&print_current_ID($G[0],$G[1]);
		print "$G[0];";

		if(exists $role{$G[0]}){
			if($role{$G[0]} eq "ped"){
				$ped++;
			}elsif($role{$G[0]} eq "adult"){
				$ad++;
			}elsif($role{$G[0]} eq "ctrl"){
				$ctrl++;
			}
		}else{
			$other++;
		}	# end if else
	
	} # end for

	if($ped + $ad+ $ctrl + $other > 0 ){
		print "\t$ped\t$ad\t$ctrl\t$other\n";
		$ped = 0 ;
		$ad = 0 ;
		$ctrl = 0;
		$other = 0;
	}else{
		print "\t0\t0\t0\t0\n";
	}
}

sub print_current_ID($$){
	my $data  = shift;
	my $gt = shift;
	#print "$gt\n";
	if($id{$data}){
		print $id{$data};
		#print ",$gt";
        
		if($role{$data} eq "ped" and $relative{$data} eq "-"){
			print "($role{$data});";
		}elsif($role{$data} eq "ped" and $relative{$data} ne "-"){
			print "($role{$data},$relative{$data});";
		}elsif($relative{$data} ne "-"){
			print "($relative{$data});";
		}else{
			print ";";
		}
	}else{
		print "$data;";
	}
}

__DATA__
Sample	Gender	ShortID	Age	role	IBD(IBD_PIHAT(0.1))
