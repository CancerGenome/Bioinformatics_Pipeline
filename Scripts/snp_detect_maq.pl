#!/usr/bin/perl
#Filename: 
#Author:Zhaowenming
#EMail:
#Date: 2009-2-1
#Last Modified: 
#History:
#Description: detect the candidate SNP to gene for Hongshu project
my $version=1.00;
my $start_time = time();

use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"ip=s","o=s","f:f","sf:n","sr:n","c:n","q:n","a:n","w:n","l:i","n:n","s","help");
if (!(defined $opts{ip} and defined $opts{o}) || defined $opts{'help'}) {   #necessary arguments
    &usage;
}
#================================================================
my $pileup = $opts{ip};
my $output  = $opts{o};
my $frequency = 0.01;

my $ssp_F = 1; #same start point,ssp, each strains has 1 start point at least, it means snp site have 2 startpoint.
my $ssp_R = 1;
my $snps_coverage = 10;
my $filter_qv = 8;
my $reads_qv  = 0; #default do not filter the low quality reads
my $context_n = 5;
my $reads_length = 35;
my $gene_number = 72;
my $switch = 0;

if (defined($opts{f})){
	$frequency = $opts{f};
}
if (defined($opts{sf})){
	$ssp_F = $opts{sf};
}
if (defined($opts{sr})){
	$ssp_R = $opts{sr};
}
if (defined($opts{c})){
	$snps_coverage = $opts{c};
	if($snps_coverage<=0){
		print "Error: the minimal snp's coverage must more than 0\n";
		exit(0);
	}
}
if (defined($opts{l})){
	$reads_length = $opts{l};
}
if (defined($opts{q})){
	$filter_qv = $opts{q};
}
if (defined($opts{a})){
	$reads_qv = $opts{a};
}
if (defined($opts{w})){
	$context_n = $opts{w};
}
if (defined($opts{n})){
	$gene_number = $opts{n};
}
if (defined($opts{s})){
	$switch = 1;
}

my $output_selected = "selected_spns_".$output;
my $output_all = "all_site_".$output;

open(IP,$pileup)   || die ("Could not open file $pileup");
#open(IM,$map_txt)  || die ("Could not open file $map_txt");
#open(IR,$raw_reads)|| die ("Could not open file $raw_reads");
open(SEL,">$output_selected");
open(ALL,">$output_all");
print SEL "#gene_id	position	Ref	depth	most_freq	second_freq	A(qv)	C(qv)	T(qv)	G(qv)	context	coverage(qv)\n";
print ALL "#gene_id	position	Ref	depth	most_freq	second_freq	A(qv)	C(qv)	T(qv)	G(qv)	context	coverage(qv)\n";

my @pileup_file  = <IP>;
#my @map_txt_file = <IM>;
#my @reads_file   = <IR>;
close IP;

my $loop = 0;
my $loop_p = 0;

while ($loop < $gene_number){
	$loop++;

	my $output_content_selected = "";
	my $output_content_all = "";

	my @coverage = (); #all reads coverage
	my @ref_coverage = ();#valid coverage
	###
	#coverage of each snp and reference site.
	###
	my @ref_seq = ();
	my @snp_A_F = (); #Forward
	my @snp_T_F = ();
	my @snp_C_F = ();
	my @snp_G_F = ();
	my @snp_A_R = (); #Reverse
	my @snp_T_R = ();
	my @snp_C_R = ();
	my @snp_G_R = ();
	
	###
	#quality value of each snp and reference site.
	###
	my @snp_A_Q_F = ();#Forward
	my @snp_T_Q_F = ();
	my @snp_C_Q_F = ();
	my @snp_G_Q_F = ();
	my @snp_A_Q_R = ();#Reverse
	my @snp_T_Q_R = ();
	my @snp_C_Q_R = ();
	my @snp_G_Q_R = ();
	my @ref_Q   = ();  #quality value of each none-snp site
	
	###
	#startpoint of each site
	###
	my @startpoint_ref_F = (); # Forward
	my @startpoint_ref_R = (); # Forward
	my @startpoint_all_F = (); # all depths
	my @startpoint_all_R = (); # all depths
	my @startpoint_A_F = (); #the start point number of A allele, if A is SNP, Forward
	my @startpoint_T_F = (); #the start point number of T allele, if T is SNP, Forward
	my @startpoint_C_F = (); #the start point number of C allele, if C is SNP, Forward
	my @startpoint_G_F = (); #the start point number of G allele, if G is SNP, Forward
	my @startpoint_A_R = (); #the start point number of A allele, if A is SNP, Reverse
	my @startpoint_T_R = (); #the start point number of T allele, if T is SNP, Reverse
	my @startpoint_C_R = (); #the start point number of C allele, if C is SNP, Reverse
	my @startpoint_G_R = (); #the start point number of G allele, if G is SNP, Reverse

	###############################################################
	##handle the pipeup file 
	###############################################################
	my %genes = {}; #keys:gene name, value:gene length
  my $flag = 0;
	for(my $i=$loop_p,my $k=0; $i<@pileup_file; $i++,$k++){
		#sample data:
		#1       730     A       4       @,,,.   @````   @~~~~   35,35,35,1,
		#yy65    1800    G       17      @TTTTTtTTTTTTTTTTt      @++++++++++++`````      @~~~~~~~~~~~~~~~~n      35,35,35,35,35,1,34,34,34,34,34,34,33,33,33,33,3,
		#yy65    1801    A       11      @GGGGGGGGGTg    @++++++`ZSG`    @~~~~~~~~~~n    35,35,35,35,35,35,34,34,34,34,2,
		#yy65    1802    A       5       @,,,,.  @``US`  @~~~~n  35,35,35,35,1,
		#yy65    1803    G       0       @       @       @
		#yy65    1804    A       0       @       @       @
		#yy65    1805    G       0       @       @       @
		#yy77    1       C       3       @,..    @```    @~~~    1,35,35,
		#yy77    2       C       4       @,...   @````   @~~~~   2,34,34,35,
		
		my $read_info     = "";
		my @tmp_arr       = ();
		my $gene_name     = "";
		my $qv_info       = "";
		if($pileup_file[$i] =~ /^\w+/){
			@tmp_arr = split("\t",$pileup_file[$i]);
			$gene_name    = $tmp_arr[0];
			$ref_seq[$k]  = $tmp_arr[2];
			$coverage[$k] = $tmp_arr[3];
			$read_info    = $tmp_arr[4];
			$qv_info      = $tmp_arr[5];
			if(defined($genes{$gene_name}) || !$flag){
				$genes{$gene_name} += 1; #will get the gene length
				$flag = 1;
				my $raw_len   = length($read_info);
				if($raw_len>1){
					###################################################
					##calculate the startpoint and quality value
					###################################################
					my $snp_ref_SP_F = ""; #different startpoint number collection
					my $snp_ref_SP_R = "";
					my $snp_all_SP_F = "";
					my $snp_all_SP_R = "";
					my $snp_A_SP_F = "";
					my $snp_T_SP_F = "";
					my $snp_C_SP_F = "";
					my $snp_G_SP_F = "";
					my $snp_A_SP_R = "";
					my $snp_T_SP_R = "";
					my $snp_C_SP_R = "";
					my $snp_G_SP_R = "";
		
					my @read_info_arr = split(//,substr($read_info,1)); #get rid of the first letter @, and split it
					my @site_on_reads = split(",",$tmp_arr[7]);#the site on reads for each letter cordinate to the read_info_arr.
					my @qv_arr = split(//,substr($qv_info,1)); ##QV
					for(my $j=0; $j<@read_info_arr; $j++){
						my $base = $read_info_arr[$j];
						my $sp = ""; #In order to use the 'index()' function to detect exists startpoint
						$sp = "S".$site_on_reads[$j]."E";
						my $qv = asc2erate($qv_arr[$j]);
						if ($base eq "A"){
							$snp_A_F[$k] += 1;
							$snp_A_Q_F[$k] += $qv;
							if(($snp_A_SP_F eq "") || index($snp_A_SP_F,$sp)<0){
								$snp_A_SP_F .= $sp . ","; #start point collection
								$startpoint_A_F[$k] += 1;
							}	
							if(($snp_all_SP_F eq "") || index($snp_all_SP_F,$sp)<0){
								$snp_all_SP_F .= $sp . ",";
								$startpoint_all_F[$k] += 1;
							}
						}elsif($base eq "a"){
							$snp_A_R[$k] += 1;
							$snp_A_Q_R[$k] += $qv;
							if(($snp_A_SP_R eq "") || index($snp_A_SP_R,$sp)<0){
								$snp_A_SP_R .= $sp . ","; #start point collection
								$startpoint_A_R[$k] += 1;
							}
							if(($snp_all_SP_R eq "") || index($snp_all_SP_R,$sp)<0){
								$snp_all_SP_R .= $sp . ",";
								$startpoint_all_R[$k] += 1;
							}
						}elsif($base eq "C"){
							$snp_C_F[$k] += 1;
							$snp_C_Q_F[$k] += $qv;
							if(($snp_C_SP_F eq "") || index($snp_C_SP_F,$sp)<0){
								$snp_C_SP_F .= $sp . ","; #start point collection
								$startpoint_C_F[$k] += 1;
							}
							if(($snp_all_SP_F eq "") || index($snp_all_SP_F,$sp)<0){
								$snp_all_SP_F .= $sp . ",";
								$startpoint_all_F[$k] += 1;
							}
						}elsif($base eq "c"){
							$snp_C_R[$k] += 1;
							$snp_C_Q_R[$k] += $qv;
							if(($snp_C_SP_R eq "") || index($snp_C_SP_R,$sp)<0){
								$snp_C_SP_R .= $sp . ","; #start point collection
								$startpoint_C_R[$k] += 1;
							}
							if(($snp_all_SP_R eq "") || index($snp_all_SP_R,$sp)<0){
								$snp_all_SP_R .= $sp . ",";
								$startpoint_all_R[$k] += 1;
							}
						}elsif($base eq "T"){
							$snp_T_F[$k] += 1;
							$snp_T_Q_F[$k] += $qv;
							if(($snp_T_SP_F eq "") || index($snp_T_SP_F,$sp)<0){
								$snp_T_SP_F .= $sp . ","; #start point collection
								$startpoint_T_F[$k] += 1;
							}
							if(($snp_all_SP_F eq "") || index($snp_all_SP_F,$sp)<0){
								$snp_all_SP_F .= $sp . ",";
								$startpoint_all_F[$k] += 1;
							}
						}elsif($base eq "t"){
							$snp_T_R[$k] += 1;
							$snp_T_Q_R[$k] += $qv;
							if(($snp_T_SP_R eq "") || index($snp_T_SP_R,$sp)<0){
								$snp_T_SP_R .= $sp . ","; #start point collection
								$startpoint_T_R[$k] += 1;
							}
							if(($snp_all_SP_R eq "") || index($snp_all_SP_R,$sp)<0){
								$snp_all_SP_R .= $sp . ",";
								$startpoint_all_R[$k] += 1;
							}
						}elsif($base eq "G"){
							$snp_G_F[$k] += 1;
							$snp_G_Q_F[$k] += $qv;
							if(($snp_G_SP_F eq "") || index($snp_G_SP_F,$sp)<0){
								$snp_G_SP_F .= $sp . ","; #start point collection
								$startpoint_G_F[$k] += 1;
							}
							if(($snp_all_SP_F eq "") || index($snp_all_SP_F,$sp)<0){
								$snp_all_SP_F .= $sp . ",";
								$startpoint_all_F[$k] += 1;
							}
						}elsif($base eq "g"){
							$snp_G_R[$k] += 1;
							$snp_G_Q_R[$k] += $qv;
							if(($snp_G_SP_R eq "") || index($snp_G_SP_R,$sp)<0){
								$snp_G_SP_R .= $sp . ","; #start point collection
								$startpoint_G_R[$k] += 1;
							}
							if(($snp_all_SP_R eq "") || index($snp_all_SP_R,$sp)<0){
								$snp_all_SP_R .= $sp . ",";
								$startpoint_all_R[$k] += 1;
							}
						}elsif($base eq ","){
							$ref_coverage[$k] += 1;
							$ref_Q[$k] += $qv;
							if(($snp_ref_SP_F eq "") || index($snp_ref_SP_F,$sp)<0){
								$snp_ref_SP_F .= $sp . ","; #start point collection
								$startpoint_ref_F[$k] += 1;
							}
							if(($snp_all_SP_F eq "") || index($snp_all_SP_F,$sp)<0){
								$snp_all_SP_F .= $sp . ",";
								$startpoint_all_F[$k] += 1;
							}
						}elsif($base eq "\."){
							$ref_coverage[$k] += 1;
							$ref_Q[$k] += $qv;
							if(($snp_ref_SP_R eq "") || index($snp_ref_SP_R,$sp)<0){
								$snp_ref_SP_R .= $sp . ","; #start point collection
								$startpoint_ref_R[$k] += 1;
							}
							if(($snp_all_SP_R eq "") || index($snp_all_SP_R,$sp)<0){
								$snp_all_SP_R .= $sp . ",";
								$startpoint_all_R[$k] += 1;
							}
						}
					}
				}
			}else{
				$loop_p = $i;
				last;
			}
		}
	}
	###################################################################################################
	##format output
	##gene_id	gene_length	position	depth	Ref.	A(qv)	C(qv)	T(qv)	G(qv)	A-freq C-freq T-freq G-freq
	###################################################################################################
	my $seq_len = 0;
	my $gene_name = "";
	foreach my $key (keys(%genes)){
		if ($genes{$key} ne ""){
			$gene_name = $key;
			$seq_len = $genes{$key};
		}
	}
	#print "#####################################################################################################\n";
	#print "gene_name:$gene_name, seq_len:$seq_len\n";
	
	for(my $i=0; $i<$seq_len; $i++){
		#print "in loops_i:$i\n";
		my $snp_A = $snp_A_F[$i] + $snp_A_R[$i];
		my $snp_C = $snp_C_F[$i] + $snp_C_R[$i];
		my $snp_T = $snp_T_F[$i] + $snp_T_R[$i];
		my $snp_G = $snp_G_F[$i] + $snp_G_R[$i];
		#print "i:$i,snp_A:$snp_A,snp_C:$snp_C,snp_T:$snp_T,snp_G:$snp_G,ref:$ref_coverage[$i]\n";
		
		my $snp_A_Q = $snp_A_Q_F[$i] + $snp_A_Q_R[$i];
		my $snp_C_Q = $snp_C_Q_F[$i] + $snp_C_Q_R[$i];
		my $snp_T_Q = $snp_T_Q_F[$i] + $snp_T_Q_R[$i];
		my $snp_G_Q = $snp_G_Q_F[$i] + $snp_G_Q_R[$i];
		
#		my $startpoint_A = $startpoint_A_F[$i] + $startpoint_A_R[$i];
#		my $startpoint_C = $startpoint_C_F[$i] + $startpoint_C_R[$i];
#		my $startpoint_T = $startpoint_T_F[$i] + $startpoint_T_R[$i];
#		my $startpoint_G = $startpoint_G_F[$i] + $startpoint_G_R[$i];

		my $most_abundant          = 0;
		my $second_abundant        = 0;
		my $most_abundant_allele   = "";
		my $second_abundant_allele = "";
		my %allele_coverage = ("A"=>$snp_A,"C"=>$snp_C,"T"=>$snp_T,"G"=>$snp_G,"REF"=>$ref_coverage[$i]);  #keys:allele, value:coverage
		my @sorted_key = sort{$allele_coverage{$b} <=> $allele_coverage{$a}} keys %allele_coverage;
		$most_abundant   = $allele_coverage{$sorted_key[0]};
		$second_abundant = $allele_coverage{$sorted_key[1]};
		$most_abundant_allele   = $sorted_key[0];
		$second_abundant_allele = $sorted_key[1];
		#print "most_abundant:$most_abundant,second_abundant:$second_abundant,most_abundant_allele:$most_abundant_allele,second_abundant_allele:$second_abundant_allele\n";
		
		#homozygote: at least include two base
		#heterozygote: only one base
		#for heterozygote, need second_abundant >= snp_coverage, for homozygote, the site which is not equal to the ref need to reserve,
		#the first restriction will reduce the cycles.
		#if(($second_abundant >= $snps_coverage) || (($most_abundant_allele ne "REF") && ($most_abundant >= $snps_coverage))){ 
		my $valid_coverage = $ref_coverage[$i]+$snp_A+$snp_C+$snp_T+$snp_G;
		my $position = $i+1; #gene site, 1-base
		my $refs        = uc($ref_seq[$i]);
		my $my_startpoint_F = $startpoint_all_F[$i];##################################
		my $my_startpoint_R = $startpoint_all_R[$i];##################################
		
		if($valid_coverage>0){
			my $freq_most   = sprintf("%.3g",$most_abundant/$valid_coverage);
			my $freq_second = sprintf("%.3g",$second_abundant/$valid_coverage);
			my $qv_most     = 0; #most abundant qv
			my $qv_second   = 0; #second abundant qv
			my $ssp_most_F  = 0; #most abundant same start point
			my $ssp_most_R  = 0;
			my $ssp_second_F= 0; #second abundant same start point
			my $ssp_second_R= 0;
#			my $flag = 1;
			#print "freq_most:$freq_most,freq_second:$freq_second\n";
			
			if($most_abundant_allele eq "A"){
				$qv_most    = sprintf("%.2g",erate2qv($snp_A_Q/$snp_A));#need not check the snp site, the most abundant is more than 0
				$ssp_most_F = $startpoint_A_F[$i];
				$ssp_most_R = $startpoint_A_R[$i];
			}elsif($most_abundant_allele eq "C"){
				$qv_most    = sprintf("%.2g",erate2qv($snp_C_Q/$snp_C));
				$ssp_most_F = $startpoint_C_F[$i];
				$ssp_most_R = $startpoint_C_R[$i];
			}elsif($most_abundant_allele eq "T"){
				$qv_most    = sprintf("%.2g",erate2qv($snp_T_Q/$snp_T));
				$ssp_most_F = $startpoint_T_F[$i];
				$ssp_most_R = $startpoint_T_R[$i];
			}elsif($most_abundant_allele eq "G"){
				$qv_most    = sprintf("%.2g",erate2qv($snp_G_Q/$snp_G));
				$ssp_most_F = $startpoint_G_F[$i];
				$ssp_most_R = $startpoint_G_R[$i];
			}elsif($most_abundant_allele eq "REF"){
				$qv_most    = sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i]));
				$ssp_most_F = $startpoint_all_F[$i]; 
				$ssp_most_R = $startpoint_all_R[$i];
				$most_abundant_allele = $refs;
#				$flag = 0; #if flag == 0, it means the most abundant is equal to ref seq.
			}
			if($second_abundant_allele eq "A"){
				$qv_second = $snp_A>0? sprintf("%.2g",erate2qv($snp_A_Q/$snp_A)):0;
				$ssp_second_F = $startpoint_A_F[$i];
				$ssp_second_R = $startpoint_A_R[$i];
			}elsif($second_abundant_allele eq "C"){
				$qv_second = $snp_C>0? sprintf("%.2g",erate2qv($snp_C_Q/$snp_C)):0;
				$ssp_second_F = $startpoint_C_F[$i];
				$ssp_second_R = $startpoint_C_R[$i];
			}elsif($second_abundant_allele eq "T"){
				$qv_second = $snp_T>0? sprintf("%.2g",erate2qv($snp_T_Q/$snp_T)):0;
				$ssp_second_F = $startpoint_T_F[$i];
				$ssp_second_R = $startpoint_T_R[$i];
			}elsif($second_abundant_allele eq "G"){
				$qv_second = $snp_G>0? sprintf("%.2g",erate2qv($snp_G_Q/$snp_G)):0;
				$ssp_second_F = $startpoint_G_F[$i];
				$ssp_second_R = $startpoint_G_R[$i];
			}elsif($second_abundant_allele eq "REF"){
				$qv_second = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
				$ssp_second_F = $startpoint_all_F[$i]; 
				$ssp_second_R = $startpoint_all_R[$i];
				$second_abundant_allele = $refs;
			}
			#variant allele freq>1%,只需要检测和ref不一致的reads
			#需要判断ref
#			if(($freq_most >=$frequency && $qv_most  >=$filter_qv && $ssp_most_F  >=$ssp_F && $ssp_most_R  >=$ssp_R &&
#			   $freq_second>=$frequency && $qv_second>=$filter_qv && $ssp_second_F>=$ssp_F && $ssp_second_R>=$ssp_R) ||
#			  ($flag==1 && $freq_most>=$frequency && $qv_most>=$filter_qv && $ssp_most_F>=$ssp_F && $ssp_most_R>=$ssp_R)){##!!here...

			$startpoint_A_F[$i] = defined($startpoint_A_F[$i])?$startpoint_A_F[$i]:0;
			$startpoint_A_R[$i] = defined($startpoint_A_R[$i])?$startpoint_A_R[$i]:0;
			$startpoint_C_F[$i] = defined($startpoint_C_F[$i])?$startpoint_C_F[$i]:0;
			$startpoint_C_R[$i] = defined($startpoint_C_R[$i])?$startpoint_C_R[$i]:0;
			$startpoint_T_F[$i] = defined($startpoint_T_F[$i])?$startpoint_T_F[$i]:0;
			$startpoint_T_R[$i] = defined($startpoint_T_R[$i])?$startpoint_T_R[$i]:0;
			$startpoint_G_F[$i] = defined($startpoint_G_F[$i])?$startpoint_G_F[$i]:0;
			$startpoint_G_R[$i] = defined($startpoint_G_R[$i])?$startpoint_G_R[$i]:0;
			
			my $format_A = $snp_A>0? "$snp_A/$startpoint_A_F[$i]:$startpoint_A_R[$i]":0;
			my $format_C = $snp_C>0? "$snp_C/$startpoint_C_F[$i]:$startpoint_C_R[$i]":0;
			my $format_T = $snp_T>0? "$snp_T/$startpoint_T_F[$i]:$startpoint_T_R[$i]":0;
			my $format_G = $snp_G>0? "$snp_G/$startpoint_G_F[$i]:$startpoint_G_R[$i]":0;
			my $qv_A = $snp_A>0? sprintf("%.2g",erate2qv($snp_A_Q/$snp_A)) : "-";
			my $qv_C = $snp_C>0? sprintf("%.2g",erate2qv($snp_C_Q/$snp_C)) : "-";
			my $qv_T = $snp_T>0? sprintf("%.2g",erate2qv($snp_T_Q/$snp_T)) : "-";
			my $qv_G = $snp_G>0? sprintf("%.2g",erate2qv($snp_G_Q/$snp_G)) : "-";
			if($refs eq "A"){
				$format_A = $ref_coverage[$i]>0? "$ref_coverage[$i]/$startpoint_ref_F[$i]:$startpoint_ref_R[$i]":0;
				$qv_A     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}elsif($refs eq "C"){
				$format_C = $ref_coverage[$i]>0? "$ref_coverage[$i]/$startpoint_ref_F[$i]:$startpoint_ref_R[$i]":0;
				$qv_C     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}elsif($refs eq "T"){
				$format_T = $ref_coverage[$i]>0? "$ref_coverage[$i]/$startpoint_ref_F[$i]:$startpoint_ref_R[$i]":0;
				$qv_T     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}elsif($refs eq "G"){
				$format_G = $ref_coverage[$i]>0? "$ref_coverage[$i]/$startpoint_ref_F[$i]:$startpoint_ref_R[$i]":0;
				$qv_G     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}
				
			##outputs context infomation
			my $left_context  = "";
			my $right_context = "";
			my $total_context = "";
			my $left_coverage_and_qv  = "";
			my $right_coverage_and_qv = "";
			my $start_context = ($i-$context_n)>=0?$i-$context_n:0;
			my $end_context   = ($i+$context_n)<=$seq_len?$i+$context_n:$seq_len-1;
			for (my $k3=$start_context; $k3<$i; $k3++){
				$left_context .= uc($ref_seq[$k3]);
				if ($ref_coverage[$k3]>0){
					$left_coverage_and_qv .= "$ref_coverage[$k3](" . sprintf("%.2g",erate2qv($ref_Q[$k3]/$ref_coverage[$k3])) ."),";
				}else{
					$left_coverage_and_qv .= "0(0),";
				}
			}
			chop($left_coverage_and_qv);  #get rid of the last ","
			for (my $k4=$i+1; $k4<=$end_context; $k4++){
				$right_context .= uc($ref_seq[$k4]);
				if ($ref_coverage[$k4]>0){
					$right_coverage_and_qv .= "$ref_coverage[$k4](" . sprintf("%.2g",erate2qv($ref_Q[$k4]/$ref_coverage[$k4])) ."),";
				}else{
					$right_coverage_and_qv .= "0(0),";
				}
			}
			chop($right_coverage_and_qv); #get rid of the last ","
			$total_context = $left_context . "\<". uc($ref_seq[$i]) . "\>" . $right_context;
			##end context
			$output_content_all .= "$gene_name\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t$most_abundant_allele:$freq_most\t$second_abundant_allele:$freq_second\t$format_A($qv_A)\t$format_C($qv_C)\t$format_T($qv_T)\t$format_G($qv_G)\t";
			$output_content_all .= "$total_context\t$left_coverage_and_qv<->$right_coverage_and_qv\n";	
			
			if ($switch){
				if(($most_abundant_allele eq $refs && $second_abundant>=$snps_coverage && $freq_second>=$frequency && $qv_second>=$filter_qv && $ssp_second_F>=$ssp_F && $ssp_second_R>=$ssp_R) ||
				   ($most_abundant_allele ne $refs && $most_abundant>=$snps_coverage && $freq_most>=$frequency && $qv_most>=$filter_qv && $ssp_most_F>=$ssp_F && $ssp_most_R>=$ssp_R)){
					$output_content_selected .= "$gene_name\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t$most_abundant_allele:$freq_most\t$second_abundant_allele:$freq_second\t$format_A($qv_A)\t$format_C($qv_C)\t$format_T($qv_T)\t$format_G($qv_G)\t";
					$output_content_selected .= "$total_context\t$left_coverage_and_qv<->$right_coverage_and_qv\n";
				}
			}else{
				if($second_abundant >= $snps_coverage &&
			    $freq_most >=$frequency && $qv_most  >=$filter_qv && $ssp_most_F  >=$ssp_F && $ssp_most_R  >=$ssp_R &&
			   $freq_second>=$frequency && $qv_second>=$filter_qv && $ssp_second_F>=$ssp_F && $ssp_second_R>=$ssp_R){##!!here...
					$output_content_selected .= "$gene_name\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t$most_abundant_allele:$freq_most\t$second_abundant_allele:$freq_second\t$format_A($qv_A)\t$format_C($qv_C)\t$format_T($qv_T)\t$format_G($qv_G)\t";
					$output_content_selected .= "$total_context\t$left_coverage_and_qv<->$right_coverage_and_qv\n";
				}##!!here...
			}
		}else{
			$output_content_all .="$gene_name\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t\-\t\-\t0(0)\t0(0)\t0(0)\t0(0)\t\-\t\-\n";############################################################
		}
	}
	print SEL $output_content_selected;
	print ALL $output_content_all;
}
##########################################################################
my $end_time = time();
my $run_time = sprintf("%.2g",($end_time - $start_time)/60);
print SEL "# Elapsed time $run_time minutes\n";
print ALL "# Elapsed time $run_time minutes\n";
close SEL;
close ALL;

sub asc2erate{
	my ($asc) = @_;
	#step1: convert the standard FASTQ format quality to Phred-like QV
	my $phred_qv = ord($asc) - 33;
	
	#step2: convert the Phred-like QV to error rate
	my $erate = exp(-$phred_qv*log(10)/10);
	
	return $erate;
}


#sub qv2erate{
#	my ($qv) = @_;
#	my $erate = exp(-$qv*log(10)/10);
#	return $erate;
#}

#convert the error rate to phred-like qv
sub erate2qv{
	my ($erate) = @_;
	my $qv = -10*log($erate)/log(10);
	return $qv;
}
#===============================================================
sub usage{
        print <<"USAGE";
Version $version
Usage:
        $0 -ip <pileup file>  -o <output file>
options:
        -ip input pileup file
        -o output file
        -f snp site frequency for filtering(default 0.01)
        -sf forward reads start point number for filtering(default 1)
        -sr reverse reads start point number for filtering(default 1)
        -c minimal snps coverage for filtering(default 10)
        -q quality of snp site for filtering(default 8)
        -a average quality for reads filtering(default 0 means not filter the low quality reads)
        -w width of the contxt(default 5)
        -l reads length (default 35)
        -n gene or chromosome or contig numbers(default 72)
        -s switch of the conditions, if set 1, only filter with SNPs, otherwise filter with both SNPs and Reference
        -help help information
USAGE
        exit(1);
}
