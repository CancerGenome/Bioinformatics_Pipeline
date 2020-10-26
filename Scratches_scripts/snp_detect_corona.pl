#!/usr/bin/perl -w
#Filename: 
#Author:Zhaowenming
#EMail:
#Date: 2009-1-4
#Last Modified: 2009-2-26
#History:
#      V1.00: outputting the snp site according to the coverage, startpoint,qv of snp site and frequency
#      V2.00: changing the outputs format, and the most abundant and the second abundant, and also add the qv restraint of reads 
#      V3.00: outputting the context of snp site, and adding the forward and reverse reads info.
#			 V4.00: make the program suit for all general GFF file and projects.
#Description: detect the candidate SNP to gene for Hongshu project
my $version=3.00;
my $start_time = time();

use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"ref=s","gff=s","cmap=s","out=s","frq:n","spf:n","spr:n","cov:n","sqv:n","aqv:n","win:n","len:i","help");
if (!(defined $opts{'ref'} and defined $opts{'gff'} and defined $opts{'cmap'} and defined $opts{'out'}) || defined $opts{'help'}) {   #necessary arguments
    &usage;
}
#================================================================
my $reference = $opts{'ref'};
my $gfffile = $opts{'gff'};
my $cmap    = $opts{'cmap'};
my $output  = $opts{'out'};
my $frequency = 0.01;

my $ssp_F = 1; #same start point,ssp, each strains has 1 start point at least, it means snp site have 2 startpoint.
my $ssp_R = 1;
my $snps_coverage = 10;
my $filter_qv = 8;
my $reads_qv  = 0; #default do not filter the low quality reads
my $context_n = 5;
my $reads_length = 35;

if (defined($opts{'frq'})){
	$frequency = $opts{'frq'};
}
if (defined($opts{'spf'})){
	$ssp_F = $opts{'spf'};
}
if (defined($opts{'spr'})){
	$ssp_R = $opts{'spr'};
}
if (defined($opts{'cov'})){
	$snps_coverage = $opts{'cov'};
	if($snps_coverage<=0){
		print "Error: the minimal snp's coverage must more than 0\n";
		exit(0);
	}
}
if (defined($opts{'len'})){
	$reads_length = $opts{'len'};
}
if (defined($opts{'sqv'})){
	$filter_qv = $opts{'sqv'};
}
if (defined($opts{'aqv'})){
	$reads_qv = $opts{'aqv'};
}
if (defined($opts{'win'})){
	$context_n = $opts{'win'};
}

my $output_selected = "selected_spns_".$output;
my $output_all = "all_site_".$output;

open(REF,$reference) || die ("Could not open file $reference\n");
open(GFF,$gfffile)   || die ("Could not open file $gfffile\n");
open(CMAP,$cmap)     || die ("Could not open file $cmap\n");
open(SEL,">$output_selected");
open(ALL,">$output_all");
print SEL "#gene_id	position	Ref	depth	most_freq	second_freq	A(qv)	C(qv)	T(qv)	G(qv)	context	coverage(qv)\n";
print ALL "#gene_id	position	Ref	depth	most_freq	second_freq	A(qv)	C(qv)	T(qv)	G(qv)	context	coverage(qv)\n";

my @reads = ();
my $i1 = 0;
while(my $line = <CMAP>){
	if($line =~ /^\d+\t(\w+)\t/){
		$reads[$i1] = $1;
		$i1++;
	}
}
my $reads_name = "";
my %seq = ""; #keys:reads_name, value:sequence.
my $i2  = 0;
while(my $line = <REF>){
    chomp($line);
    if ($line =~ /^\>/){
        $reads_name = $reads[$i2];
        $seq{$reads_name} = "";
        #$reads[$i] = $reads_name;
        $i2++;
    }else{
        $seq{$reads_name} .= $line;
    }
}
close REF;

my @gff_str = <GFF>;
close GFF;

my $starting = 0;
my $ending = 0;
#my $total_length = 0; 
my $loop_n = 0;

for(my $j=0; $j<@reads; $j++){
	my $output_content_selected = "";
	my $output_content_all = "";

	my $seq_len = length($seq{$reads[$j]});

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
	my %snp_ref_SP_F  = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Forward
	my %snp_ref_SP_R = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Reverse
	my %snp_A_SP_F = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Forward
	my %snp_T_SP_F = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Forward
	my %snp_C_SP_F = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Forward
	my %snp_G_SP_F = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Forward
	my %snp_A_SP_R = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Reverse
	my %snp_T_SP_R = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Reverse
	my %snp_C_SP_R = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Reverse
	my %snp_G_SP_R = {}; #keys: snp site, value:SNP position startpoint, seperated by comma(,), Reverse
	my @startpoint_ref_F  = (); # Forward
	my @startpoint_ref_R  = (); # Forward
	my @startpoint_A_F = (); #the start point number of A allele, if A is SNP, Forward
	my @startpoint_T_F = (); #the start point number of T allele, if T is SNP, Forward
	my @startpoint_C_F = (); #the start point number of C allele, if C is SNP, Forward
	my @startpoint_G_F = (); #the start point number of G allele, if G is SNP, Forward
	my @startpoint_A_R = (); #the start point number of A allele, if A is SNP, Reverse
	my @startpoint_T_R = (); #the start point number of T allele, if T is SNP, Reverse
	my @startpoint_C_R = (); #the start point number of C allele, if C is SNP, Reverse
	my @startpoint_G_R = (); #the start point number of G allele, if G is SNP, Reverse
	
	@ref_seq = split (//,$seq{$reads[$j]});
	
	for(my $n=$loop_n; $n<@gff_str; $n++){
		if($gff_str[$n] =~ /\w+\t\w+\t\w+\t(\d+)\t(\d+)\t\S+\t(\S+)\t\S+\t(b=(\w+))?;g=\w+;i=(\d+);p=(\d\.\d+);(q=((\d+,?)+);)?(r=((,?\w+)+);)?(s=((,?\w+)+);)?u=/){
    	my $rstart    = $1 - 1; #change it to 0-base
    	my $rend      = $2 - 1; #change it to 0-base
			my $direction = $3;
			my @reads_seq = split(//,$5);
			my $chr_No    = $6;              #the ID of each chromosome, it is defined in .cmap file
			my @reads_qv  = split(/,/,$9);   #q=(35,22,.....)
			#my @color_error_site = split(/,/,$12);  #r=(22_2,35_3)
	  	my @error_info= defined($15)? split(/,/,$15):();  #s=(a22,a35)
	  	
	  	##use the chr_ID distinguish each chromosome.
	  	if ($chr_No != ($j+1)){
	  		$loop_n = $n;
    		last;
	  	}
	  	##filter low quality reads
#	  	if ($reads_qv != 0 ){
		  	my $total_error_rate = 0;
		  	for (my $m=0; $m<$reads_length; $m++){
		  		$reads_qv[$m] = qv2erate($reads_qv[$m]); #transfer the qv to error rate
		  		$total_error_rate += $reads_qv[$m];
		  	}
		  	if (erate2qv($total_error_rate/$reads_length) <  $reads_qv){
		  		next;
		  	}
#	  	}
	
	  	my $sp = 0;
  		if ($direction eq "+"){
	  		$sp = "S".$rstart."E"; #In order to use the 'index()' function to detect exists startpoint
	  		if (!defined($snp_ref_SP_F{$rstart}) || index($snp_ref_SP_F{$rstart},$sp)<0){
					$snp_ref_SP_F{$rstart} .= $sp . ",";    #start point collection
					$startpoint_ref_F[$rstart] += 1; #0-base array.
				}
  			for(my $k=0; $k<$reads_length; $k++){
  				$coverage[$rstart+$k] += 1;
  				if ($k<$reads_length-1){ #do not calculate the last base, bacause the last base sequencing only once.
  					$ref_coverage[$rstart+$k] += 1;
  					$ref_Q[$rstart+$k] += $reads_qv[$k];  ##############
  				}
  			}
  		}else{
	  		$sp = "S".$rend."E"; #In order to use the 'index()' function to detect exists startpoint
	  		if (!defined($snp_ref_SP_R{$rend}) || index($snp_ref_SP_R{$rend},$sp)<0){
					$snp_ref_SP_R{$rend} .= $sp . ",";    #start point collection
					$startpoint_ref_R[$rend] += 1;
				}
  			for(my $k=0; $k<$reads_length; $k++){
  				$coverage[$rend-$k] += 1;
  				if ($k<$reads_length-1){ #do not calculate the last base, bacause the last base sequencing only once.
						$ref_coverage[$rend-$k] += 1;
						$ref_Q[$rend-$k] += $reads_qv[$k];   ##############
					}
  			}
  		}
  		
			if(@error_info>0){
				for (my $m=0; $m<@error_info; $m++){
					my $site = substr($error_info[$m],1);
  				my $startchar = substr($error_info[$m],0,1); #first char: a r g y b
  				if(($error_info[$m] =~ /^[rgy]/) && ($startchar eq substr($error_info[$m+1],0,1))){ #do not calculate the coverage when the char of reads is not equal to reference.
  					if ($direction eq "+"){
  						$ref_coverage[$rstart+$site-1] -= 1;
  						$ref_Q[$rstart+$site-1] -= $reads_qv[$site-1];
  					}else{
  						$ref_coverage[$rend-$site+1] -= 1;
  						$ref_Q[$rend-$site+1] -= $reads_qv[$site-1];
  					}
  				}
  				if(($error_info[$m] =~ /^[g]/) && ($startchar eq substr($error_info[$m+1],0,1))){
  					my $snp = $reads_seq[$site-1];
  					my $qv  = $reads_qv[$site-1];
  					
  					if ($direction eq "+"){
  						$sp = "S".$rstart."E"; #In order to use the 'index()' function to detect exists startpoint
  						if($snp eq "a" ){
  							$snp_A_F[$rstart+$site-1]   += 1;
  							$snp_A_Q_F[$rstart+$site-1] += $qv;
  							if (!defined($snp_A_SP_F{$rstart+$site-1}) || index($snp_A_SP_F{$rstart+$site-1},$sp)<0){
  								$snp_A_SP_F{$rstart+$site-1}     .= $sp . ",";    #start point collection
  								$startpoint_A_F[$rstart+$site-1] += 1;
  							}
  						}elsif($snp eq "t"){
  							$snp_T_F[$rstart+$site-1] += 1;
  							$snp_T_Q_F[$rstart+$site-1] += $qv;
  							if (!defined($snp_T_SP_F{$rstart+$site-1}) || index($snp_T_SP_F{$rstart+$site-1},$sp)<0){
  								$snp_T_SP_F{$rstart+$site-1} .= $sp . ",";    #start point collection
  								$startpoint_T_F[$rstart+$site-1] += 1;
  							}
  						}elsif($snp eq "c"){
  							$snp_C_F[$rstart+$site-1] += 1;
  							$snp_C_Q_F[$rstart+$site-1] += $qv;
  							if (!defined($snp_C_SP_F{$rstart+$site-1}) || index($snp_C_SP_F{$rstart+$site-1},$sp)<0){
  								$snp_C_SP_F{$rstart+$site-1} .= $sp . ",";    #start point collection
  								$startpoint_C_F[$rstart+$site-1] += 1;
  							}
  						}elsif($snp eq "g"){
  							$snp_G_F[$rstart+$site-1] += 1;
  							$snp_G_Q_F[$rstart+$site-1] += $qv;
  							if (!defined($snp_G_SP_F{$rstart+$site-1}) || index($snp_G_SP_F{$rstart+$site-1},$sp)<0){
  								$snp_G_SP_F{$rstart+$site-1} .= $sp . ",";    #start point collection
  								$startpoint_G_F[$rstart+$site-1] += 1;
  							}
  						}else{
  							print "SNP letter error: $snp at line:$n\n";
  						}
  					}else{
  						$sp = "S".$rend."E"; #In order to use the 'index()' function to detect exists startpoint
  						if($snp eq "a" ){
  							$snp_T_R[$rend-$site+1] += 1; #a-->t
  							$snp_T_Q_R[$rend-$site+1] += $qv;
  							if (!defined($snp_T_SP_R{$rend-$site+1}) || index($snp_T_SP_R{$rend-$site+1},$sp)<0){
  								$snp_T_SP_R{$rend-$site+1} .= $sp . ",";    #start point collection
  								$startpoint_T_R[$rend-$site+1] += 1;
  							}
  						}elsif($snp eq "t"){
  							$snp_A_R[$rend-$site+1] += 1; #t-->a
  							$snp_A_Q_R[$rend-$site+1] += $qv;
  							if (!defined($snp_A_SP_R{$rend-$site+1}) || index($snp_A_SP_R{$rend-$site+1},$sp)<0){
  								$snp_A_SP_R{$rend-$site+1} .= $sp . ",";    #start point collection
  								$startpoint_A_R[$rend-$site+1] += 1;
  							}
  						}elsif($snp eq "c"){
  							$snp_G_R[$rend-$site+1] += 1; #c-->g
  							$snp_G_Q_R[$rend-$site+1] += $qv;
  							if (!defined($snp_G_SP_R{$rend-$site+1}) || index($snp_G_SP_R{$rend-$site+1},$sp)<0){
  								$snp_G_SP_R{$rend-$site+1} .= $sp . ",";    #start point collection
  								$startpoint_G_R[$rend-$site+1] += 1;
  							}
  						}elsif($snp eq "g"){
  							$snp_C_R[$rend-$site+1] += 1; #g-->c
  							$snp_C_Q_R[$rend-$site+1] += $qv;
  							if (!defined($snp_C_SP_R{$rend-$site+1}) || index($snp_C_SP_R{$rend-$site+1},$sp)<0){
  								$snp_C_SP_R{$rend-$site+1} .= $sp . ",";    #start point collection
  								$startpoint_C_R[$rend-$site+1] += 1;
  							}
  						}else{
  							print "SNP letter error: $snp at line:$n\n";
  						}
  					}
  				}
				}
			}
    }
	}
	
	#format output############################
	#gene_id	gene_length	position	depth	Ref.	A(qv)	C(qv)	T(qv)	G(qv)	A-freq C-freq T-freq G-freq
	##########################################
	for(my $i=0; $i<$seq_len; $i++){
		my $snp_A = $snp_A_F[$i] + $snp_A_R[$i];
		my $snp_C = $snp_C_F[$i] + $snp_C_R[$i];
		my $snp_T = $snp_T_F[$i] + $snp_T_R[$i];
		my $snp_G = $snp_G_F[$i] + $snp_G_R[$i];
		
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
		
		#for heterozygote, need second_abundant >= snp_coverage, for homozygote, the site which is not equal to the ref need to reserve,
		#the first restriction will reduce the cycles.
		######if(($second_abundant >= $snps_coverage) || (($most_abundant_allele ne "REF") && ($most_abundant >= $snps_coverage))){ 
		my $valid_coverage = $ref_coverage[$i]+$snp_A+$snp_C+$snp_T+$snp_G;
		my $position = $i+1; #gene site, 1-base
		my $refs        = uc($ref_seq[$i]);
		my $my_startpoint_F = 0;
		my $my_startpoint_R = 0;
		my $sp_S_F = ($i-35+1)>=0 ? ($i-35+1):0;
		my $sp_E_F = $i;
		my $sp_S_R = $i;
		my $sp_E_R = ($i+35-1)<=$seq_len ? ($i+35-1):$seq_len;
		for(my $k1=$sp_S_F; $k1<=$sp_E_F; $k1++){
			$my_startpoint_F += $startpoint_ref_F[$k1];
		}
		for(my $k2=$sp_S_R; $k2<=$sp_E_R; $k2++){
			$my_startpoint_R += $startpoint_ref_R[$k2];
		}
		if($valid_coverage>0){
			my $freq_most   = sprintf("%.3g",$most_abundant/$valid_coverage);
			my $freq_second = sprintf("%.3g",$second_abundant/$valid_coverage);
			my $qv_most     = 0; #most abundant qv
			my $qv_second   = 0; #second abundant qv
			my $ssp_most_F  = 0; #most abundant same start point
			my $ssp_most_R  = 0;
			my $ssp_second_F= 0; #second abundant same start point
			my $ssp_second_R= 0;
			my $flag = 1;
				
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
				$ssp_most_F = $reads_length; ##!!could not calculate the ssp to the allele site which is same to ref, 
				                               ##so give max value in order to following filter.
				$ssp_most_R = $reads_length;
				$most_abundant_allele = $refs;
				$flag = 0; #if flag == 0, it means the most abundant is equal to ref seq.
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
				$ssp_second_F = $reads_length; ##!!could not calculate the ssp to the allele site which is same to ref,
				                                 ##so give max value in order to following filter.
				$ssp_second_R = $reads_length;
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
				$format_A = $ref_coverage[$i];
				$qv_A     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}elsif($refs eq "C"){
				$format_C = $ref_coverage[$i];
				$qv_C     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}elsif($refs eq "T"){
				$format_T = $ref_coverage[$i];
				$qv_T     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}elsif($refs eq "G"){
				$format_G = $ref_coverage[$i];
				$qv_G     = $ref_coverage[$i]>0? sprintf("%.2g",erate2qv($ref_Q[$i]/$ref_coverage[$i])):0;
			}
				
			##outputs context infomation
			##########################################################
			my $left_context  = "";
			my $right_context = "";
			my $total_context = "";
			my $left_coverage_and_qv  = "";
			my $right_coverage_and_qv = "";
			my $start_context = ($i-$context_n)>=0?$i-$context_n:0;
			my $end_context   = ($i+$context_n)<=$seq_len?$i+$context_n:$seq_len;
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
			##########################################################
			#end context
			
			$output_content_all .= "$reads[$j]\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t$most_abundant_allele:$freq_most\t$second_abundant_allele:$freq_second\t$format_A($qv_A)\t$format_C($qv_C)\t$format_T($qv_T)\t$format_G($qv_G)\t";
			$output_content_all .= "$total_context\t$left_coverage_and_qv<->$right_coverage_and_qv\n";
			if(($most_abundant_allele eq $refs && $second_abundant>=$snps_coverage && $freq_second>=$frequency && $qv_second>=$filter_qv && $ssp_second_F>=$ssp_F && $ssp_second_R>=$ssp_R) ||
			   ($most_abundant_allele ne $refs && $most_abundant>=$snps_coverage && $freq_most>=$frequency && $qv_most>=$filter_qv && $ssp_most_F>=$ssp_F && $ssp_most_R>=$ssp_R)){
				$output_content_selected .= "$reads[$j]\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t$most_abundant_allele:$freq_most\t$second_abundant_allele:$freq_second\t$format_A($qv_A)\t$format_C($qv_C)\t$format_T($qv_T)\t$format_G($qv_G)\t";
				$output_content_selected .= "$total_context\t$left_coverage_and_qv<->$right_coverage_and_qv\n";
			}
		}else{
			$output_content_all .="$reads[$j]\t$position\t$refs\t$coverage[$i]/$my_startpoint_F:$my_startpoint_R\t\-\t\-\t0(0)\t0(0)\t0(0)\t0(0)\t\-\t\-\n";############################################################
		}
	}
	print SEL $output_content_selected;
	print ALL $output_content_all;
}
my $end_time = time();
my $run_time = sprintf("%.2g",($end_time - $start_time)/60);
print SEL "# Elapsed time $run_time minutes\n";
print ALL "# Elapsed time $run_time minutes\n";
close SEL;
close ALL;

sub qv2erate{
	my ($qv) = @_;
	my $erate = exp(-$qv*log(10)/10);
	return $erate;
}

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
        $0 -ref <reference file> -gff <gff file> -cmap <Cmap file> -out <output file>
options:
        -ref  input concatenated and validated reference file
        -gff  input annotate.gff file, which include QV information.
        -cmap input Cmap file
        -out  output file
        -frq  snp site frequency for filtering(default 0.01)
        -spf  forward reads start point number for filtering(default 1)
        -spr  reverse reads start point number for filtering(default 1)
        -cov  minimal snps coverage for filtering(default 10)
        -sqv  quality of snp site for filtering(default 8)
        -aqv  average quality for reads filtering(default 0 means not filter the low quality reads)
        -win  windows size of the contxt(default 5)
        -len  reads length (default 35)
        -help help information
USAGE
        exit(1);
}
