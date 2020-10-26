#!/bin/bash
if [ $# -le 2 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/PathogenicV4_pipeline.sh <VCF.GZ> <Sample.list> <Pos.list>
#      Description:
#      This is the pipeline for pathogenic annotation V4 (same with COL5A1 paper)
#      Step 1: Both gnomAD_exome_NFE and gnomAD_genome_NFE <= 0.1%.	
#      Step 2: LOF or ClinVar or In silico prediction	
#      LOF definition: frameshift_deletion, frameshift_insertion, stopgain, stoploss, splicing,  nonframeshift_deletion, nonframeshift_insertion,	
#      ClinVar: pathogenic/likely pathogenic	
#      (1) any 2 of 3 ensemble scores predicted a deleterious effect: metaSVM, metaLR, M-Cap;	
#      (2) any 6 of 8 of the following effects were predicted by functional scores: SIFT, deleterious; Polyphen2 HDIV, deleterious or possibly damaging; Polyphen2 HVAR, deleterious or possibly damaging; LRT, deleterious; MutationTaster, deleterious; MutationAssessor, high or medium; FATHMM, deleterious; PROVEAN, deleterious;	
#      (3) CADD phred score greater than 20	
#                  
#      Future: to add criteria for allele frequency, CADD 
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 06 Dec 2019 10:15:26 AM EST
#########################################################################
"
exit
fi
VCF=$1
SAMPLE=$2
POS=$3

#----- Create Header
bcftools view -c1 -f "PASS" -R $POS -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | head -n1 > header 
bcftools view -c1 -f "PASS" -R $POS -S $SAMPLE $VCF | call_header4 - 2>err | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m - | awk '!($30>0.001 || $32>0.001)'  | cat header - | sed 's/\tGT\tGenotype$//' | Collapse_PosV2.pl -s 111 - | cut -f1-52,81- | awk 'BEGIN{OFS="\t"}{print $83,$84,$85,$86,$87,$0}' > Pathogenic.All.trans
Split_Pos.pl Pathogenic.All.trans > Pathogenic.All.trans.split
