#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Run_BurdenTest_fromPathoVarV16_CombineTraditionalyBurDenTest.sh <Prefix> <VCF>
#      Description:
#      This is a sub module for ~/bin/Run_BurdenTest_fromPathoVarV16.sh
#      For burden test traditional way synonymous variants, we need to combine the result included in excel. 
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 10 Apr 2020 04:21:36 PM EDT
#########################################################################
"
exit
fi
prefix=$1
#VCF='/home/yulywang/FMD/anno/Ped.EUR.afterQC.vcf.gz'
VCF=`readlink -f $2`

# Need to clean up
# Combine files
combine_epacts_gene_name_V2.pl - | GeneNameTranslate.pl - >  $prefix\.burden.all
Rscript /home/yulywang/bin/Brown_Fisher_Method_LOF_Nonsyn_0.01_0.05.R $prefix\.burden.all
Format_Brown_Result.pl $prefix\.burden.allfisher.brown.method > $prefix\.burden.allfisher.tmp

## Because epacts annotation used old name should replace all old name to new name
GeneNameTranslate.pl Syn_0.0001/group.file > cache; mv cache Syn_0.0001/group.file 
GeneNameTranslate.pl Syn_0.001/group.file > cache; mv cache Syn_0.001/group.file 
GeneNameTranslate.pl Syn_0.01/group.file > cache; mv cache Syn_0.01/group.file 
GeneNameTranslate.pl Syn_0.05/group.file > cache; mv cache Syn_0.05/group.file 

# Prepare sample and pos for variant details, only process at least one p<= 1e-2 
awk '$NF~/P/ || $NF<=1e-2'  $prefix\.burden.all | sort -k27,27g > $prefix\.burden.1e-2 # only process these variants
cut -f1 $prefix\.ped |sed '1d' > sample.list
cat Syn_0.0001/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > Syn_0.0001/pos.list
cat Syn_0.001/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > Syn_0.001/pos.list
cat Syn_0.01/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > Syn_0.01/pos.list
cat Syn_0.05/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > Syn_0.05/pos.list

### Query and get details
BurdenTest_VariantDetails.sh $VCF sample.list Syn_0.0001/pos.list > Syn_0.0001/burden.1e-2.details
BurdenTest_VariantDetails.sh $VCF sample.list Syn_0.001/pos.list > Syn_0.001/burden.1e-2.details
BurdenTest_VariantDetails.sh $VCF sample.list Syn_0.01/pos.list > Syn_0.01/burden.1e-2.details
BurdenTest_VariantDetails.sh $VCF sample.list Syn_0.05/pos.list > Syn_0.05/burden.1e-2.details

### Prepare for output excel, and variant details
if [[ $prefix == "ped"* ]]; then
	add_total_case.pl -n2,4 -g15 Syn_0.0001/burden.1e-2.details $prefix\.burden.allfisher.tmp | add_total_case.pl -n2,4 -g15 Syn_0.001/burden.1e-2.details -|  add_total_case.pl -n2,4 -g15 Syn_0.01/burden.1e-2.details - | add_total_case.pl -n2,4 -g15 Syn_0.05/burden.1e-2.details - |sort -k36,36g > $prefix\.burden.forexcel
elif [[ $prefix == "adult_scad"* ]]; then
	add_total_case.pl -n5,4 -g15 Syn_0.0001/burden.1e-2.details $prefix\.burden.allfisher.tmp | add_total_case.pl -n5,4 -g15 Syn_0.001/burden.1e-2.details -|  add_total_case.pl -n5,4 -g15 Syn_0.01/burden.1e-2.details - | add_total_case.pl -n5,4 -g15 Syn_0.05/burden.1e-2.details - |sort -k36,36g > $prefix\.burden.forexcel
elif [[ $prefix == "adult"* ]]; then
	add_total_case.pl -n3,4 -g15 Syn_0.0001/burden.1e-2.details $prefix\.burden.allfisher.tmp | add_total_case.pl -n3,4 -g15 Syn_0.001/burden.1e-2.details -|  add_total_case.pl -n3,4 -g15 Syn_0.01/burden.1e-2.details - | add_total_case.pl -n3,4 -g15 Syn_0.05/burden.1e-2.details - |sort -k36,36g > $prefix\.burden.forexcel
fi

#### Final Output for excel
awk '$1!="Gene" && $1!="-" && $6!="multichrs"' $prefix\.burden.forexcel | head -n 100 |fetch.pl -h -q1 -d15 - Syn_0.05/burden.1e-2.details  > Top100.variant.detail.forexcel
grep -v multichr $prefix\.burden.forexcel | awk '$36<=0.1 || $1 == "Gene"' > variant.forexcel
grep  -E 'Gene|multichr' $prefix\.burden.forexcel  > pathway.forexcel
