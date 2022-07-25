#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/PathogenicV4_pipeline.sh <VCF.GZ> <Sample.list> 
#      Description:
#      This is the pipeline for pathogenic annotation V4.3, for peds
#      Pathogenic Variants
#      Nonsyn variant:
#      Both gnomAD_exome_NFE/ALL and gnomAD_genome_NFE/ALL <= 0.01% & CADD>=20 

#      LOF will added as separate flag
#      Both gnomAD_exome_NFE/ALL and gnomAD_genome_NFE/ALL <= 0.01% including frameshift_deletion, frameshift_insertion, stopgain, stoploss, splicing, nonframeshift_deletion, nonframeshift_insertion,
#       
#      Update 02/04/2020: no position information, no QD 3 criteria
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 06 Dec 2019 10:15:26 AM EST
#########################################################################
"
exit
fi
VCF=$1
SAMPLE=$2

#----- Create Header -----
bcftools view -c1 -f "PASS" -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | head -n1 > header 
# Update ClinVar pathogenic variants
bcftools view -c1 -f "PASS" -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | awk '!($30>0.0001 || $32>0.0001) || $2== 1'  | cat header - | sed 's/\tGT\tGenotype$//' | Collapse_PosV2.pl -s 111 - | cut -f1-52,81- | awk 'BEGIN{OFS="\t"}{print $83,$84,$85,$86,$87,$0}' > Pathogenic.All.trans
# Update CliniVar Pathogenic variants
awk '$6+$7+$10>=1 || $10 =="CADD"' Pathogenic.All.trans | awk '!($34>0.0001 || $35>0.0001 || $36>0.0001 || $37 >0.0001) || $18 =="QD" || $7 == 1' | Split_Pos.pl - > Pathogenic.All.trans.split
