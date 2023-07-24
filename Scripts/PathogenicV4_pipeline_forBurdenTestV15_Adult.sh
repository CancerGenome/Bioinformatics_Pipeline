#!/bin/bash
if [ $# -le 1 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/PathogenicV4_pipeline.sh <VCF.GZ> <Sample.list> 
#      Description:
#      This is the pipeline for pathogenic annotation V4.3
#      Pathogenic Variants
#      Nonsyn variant:
#      Both gnomAD_exome_NFE/ALL and gnomAD_genome_NFE/ALL <= 0.1% & CADD>=20

#      LOF will added as separate flag
#      Both gnomAD_exome_NFE/ALL and gnomAD_genome_NFE/ALL <= 0.1% including frameshift_deletion, frameshift_insertion, stopgain, stoploss, splicing, nonframeshift_deletion, nonframeshift_insertion,

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
# Update ClinVar pathogenic variant
bcftools view -c1 -f "PASS" -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | awk '!($30>0.001 || $32>0.001) || $2== 1'  | cat header - | sed 's/\tGT\tGenotype$//' | Collapse_PosV2.pl -s 111 - | cut -f1-52,81- | awk 'BEGIN{OFS="\t"}{print $83,$84,$85,$86,$87,$0}' > Pathogenic.All.trans
# Update CliniVar Pathogenic variants
awk '$6+$7+$10>=1 || $10 =="CADD"' Pathogenic.All.trans | awk '!($34>0.001 || $35>0.001 || $36>0.001 || $37 >0.001) || $18 =="QD" || $7 == 1' | Split_Pos.pl - > Pathogenic.All.trans.split

#### Archive commandline
#----- Create Header
#bcftools view -c1 -f "PASS" -R $POS -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | head -n1 > header 
#bcftools view -c1 -f "PASS" -R $POS -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | awk '!($30>0.001 || $32>0.001)'  | cat header - | sed 's/\tGT\tGenotype$//' | Collapse_PosV2.pl -s 111 - | cut -f1-52,81- | awk 'BEGIN{OFS="\t"}{print $83,$84,$85,$86,$87,$0}' > Pathogenic.All.trans
# this is the new adult criteria, it will be included as a subset of previous pathogenic result
#awk '$6+$10>=1 || $10 =="CADD"' Pathogenic.All.trans |awk '$18 =="QD" || $18>=3' | awk '!($34>0.001 || $35>0.001 || $36>0.001 || $37 >0.001)  || $18=="QD"' | Split_Pos.pl - > Pathogenic.All.trans.split
