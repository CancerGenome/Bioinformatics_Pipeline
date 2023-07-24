#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Run_BurdenTest_fromPathoVarV16_CombineTraditionalyBurDenTest.sh <Prefix> <VCF>
#      Description:
#      This is a sub module for ~/bin/Run_BurdenTest_fromPathoVarV16.sh
#      For burden test traditional way, we need to combine the result included in excel. 
#      This pipeline will export variant (BrowP<=0.1), all pathways, Top1000 Gene details
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
Rscript ~/bin/Brown_Fisher_Method_LOF_Nonsyn_0.01_0.05.R  $prefix\.burden.all
Format_Brown_Result.pl $prefix\.burden.allfisher.brown.method > $prefix\.burden.allfisher.tmp

## Because epacts annotation used old name should replace all old name to new name
GeneNameTranslate.pl LOF_0.01/group.file > cache; mv cache LOF_0.01/group.file 
GeneNameTranslate.pl LOF_0.05/group.file > cache; mv cache LOF_0.05/group.file 
GeneNameTranslate.pl LOF_Nonsyn_0.01/group.file > cache; mv cache LOF_Nonsyn_0.01/group.file 
GeneNameTranslate.pl LOF_Nonsyn_0.05/group.file > cache; mv cache LOF_Nonsyn_0.05/group.file 

# Prepare sample and pos for variant details, only process at least one p<= 1e-2 
awk '$NF~/P/ || $NF<=1e-2'  $prefix\.burden.all | sort -k27,27g > $prefix\.burden.1e-2 # only process these variants
cat $prefix\.ped |sed '1d' | cut -f1 > sample.list
cat LOF_0.01/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > LOF_0.01/pos.list
cat LOF_0.05/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > LOF_0.05/pos.list
cat LOF_Nonsyn_0.01/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > LOF_Nonsyn_0.01/pos.list
cat LOF_Nonsyn_0.05/group.file  | fetch.pl -q1 -d1 $prefix\.burden.1e-2 - | cut -f2- | GapTrans  -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > LOF_Nonsyn_0.05/pos.list

### Query and get details
BurdenTest_VariantDetails.sh $VCF sample.list LOF_0.01/pos.list | awk '$11=="AF" || $11<= 0.01' > LOF_0.01/burden.1e-2.details
BurdenTest_VariantDetails.sh $VCF sample.list LOF_0.05/pos.list | awk '$11=="AF" || $11<= 0.05'> LOF_0.05/burden.1e-2.details
BurdenTest_VariantDetails.sh $VCF sample.list LOF_Nonsyn_0.01/pos.list | awk '$11=="AF" || $11<= 0.01' > LOF_Nonsyn_0.01/burden.1e-2.details
BurdenTest_VariantDetails.sh $VCF sample.list LOF_Nonsyn_0.05/pos.list | awk '$11=="AF" || $11<= 0.05' > LOF_Nonsyn_0.05/burden.1e-2.details

### Prepare for output excel, and variant details
if [[ $prefix == "ped"* ]]; then
	add_total_case.pl -n2,4 -g15 LOF_0.01/burden.1e-2.details $prefix\.burden.allfisher.tmp | add_total_case.pl -n2,4 -g15 LOF_0.05/burden.1e-2.details -|  add_total_case.pl -n2,4 -g15 LOF_Nonsyn_0.01/burden.1e-2.details - | add_total_case.pl -n2,4 -g15 LOF_Nonsyn_0.05/burden.1e-2.details - |sort -k36,36g > $prefix\.burden.forexcel
elif [[ $prefix == "adult_scad"* ]]; then
	add_total_case.pl -n5,4 -g15 LOF_0.01/burden.1e-2.details $prefix\.burden.allfisher.tmp | add_total_case.pl -n5,4 -g15 LOF_0.05/burden.1e-2.details -|  add_total_case.pl -n5,4 -g15 LOF_Nonsyn_0.01/burden.1e-2.details - | add_total_case.pl -n5,4 -g15 LOF_Nonsyn_0.05/burden.1e-2.details - |sort -k36,36g > $prefix\.burden.forexcel
elif [[ $prefix == "adult"* ]]; then
	add_total_case.pl -n3,4 -g15 LOF_0.01/burden.1e-2.details $prefix\.burden.allfisher.tmp | add_total_case.pl -n3,4 -g15 LOF_0.05/burden.1e-2.details -|  add_total_case.pl -n3,4 -g15 LOF_Nonsyn_0.01/burden.1e-2.details - | add_total_case.pl -n3,4 -g15 LOF_Nonsyn_0.05/burden.1e-2.details - |sort -k36,36g > $prefix\.burden.forexcel
fi

#### Final Output for excel
awk '$1!="Gene" && $1!="-" && $6!="multichrs"' $prefix\.burden.forexcel | head -n 100 |fetch.pl -h -q1 -d15 - LOF_Nonsyn_0.05/burden.1e-2.details  > Top100.variant.detail.forexcel
grep -v multichr $prefix\.burden.forexcel | awk '$36<=0.1 || $1 == "Gene"' > variant.forexcel
grep  -E 'Gene|multichr' $prefix\.burden.forexcel  > pathway.forexcel

#----------------------
#bcftools view -R pos.list -S sample.list $VCF | call_header - | awk '$NF~/\/1/ || $NF~/\/2/ || $NF ~/VQ/' | perl ~/bin/Collapse_Pos.pl -p2 -s 54 - | awk '{print $54"\t"$55"\t"$56"\t"$57"\t"$58"\t"$0}' > $prefix\.burden.1e-2.detail
#
##grep \. $prefix\.burden.allfisher.brown.method /dev/null | Format_Brown_Result.pl - > $prefix\.burden.allfisher.brown.method.tsv
#
### For pvalue at least 0.01 data
#cat */group.file| fetch.pl -q1 -d1 $prefix\.burden.1e-2 - |  cut -f2- | GapTrans -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > pos.list
#
## add clinical file for specific samples with significant genes, with clinical feature
#awk '$NF<=0.1' $prefix\.burden.allfisher.brown.method | cut -f1 | grep -wf - */group.file | cut -f2- | GapTrans -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > pos.list2
#bcftools view -R pos.list2 -S sample.list $VCF | call_header - | awk '$NF~/\/1/ || $NF~/\/2/ || $NF ~/VQ/' | perl ~/bin/Collapse_Pos.pl -p2 -s 54 - | awk '{print $54"\t"$55"\t"$56"\t"$57"\t"$58"\t"$0}' | perl ~/bin/Split_Pos.pl - | awk '$12<=0.05 || $12 == "AF"' > $prefix\.burden.MAF0.1.clinical.detail
#######----- Burden Test Traditionally LOF0.01/0.05 LOF_nonsyn 0.01/0.05------ #####
#echo "Burden Test Traditionally LOF0.01/0.05 LOF_nonsyn 0.01/0.05 "
#
##### Example
## First combine Deleterious Variant First
##combine_epacts_gene_name_V3.pl - >  $prefix\.burden.all
##Rscript ~/bin/Brown_Fisher_Method.R $prefix\.burden.all
##Format_Brown_ResultV2.pl $prefix\.burden.allfisher.brown.method > $prefix\.burden.allfisher.tmp
##sed '1d' sel | cut -f1-4 > Pos.list
##
### Second prepare for output excel, and variant details
##if [[ $prefix == "ped"* ]]; then
##	#PathogenicV4_pipeline_forBurdenTestV15_Ped.sh group.vcf.gz Sample.list Pos.list
##	cp Pathogenic.All.trans.split $prefix\.burden.detail
##	add_total_case.pl -n 3,5 -g21 $prefix\.burden.detail $prefix\.burden.allfisher.tmp | sort -k17,17g | awk '$17!="NA"' > $prefix\.burden.allfisher.forexcel
##elif [[ $prefix == "adult_scad"* ]]; then
##	#PathogenicV4_pipeline_forBurdenTestV15_Adult.sh group.vcf.gz Sample.list Pos.list
##	cp Pathogenic.All.trans.split $prefix\.burden.detail
##	add_total_case.pl -n 6,5 -g21 $prefix\.burden.detail $prefix\.burden.allfisher.tmp | sort -k17,17g | awk '$17!="NA"' > $prefix\.burden.allfisher.forexcel
##elif [[ $prefix == "adult"* ]]; then
##	#PathogenicV4_pipeline_forBurdenTestV15_Adult.sh group.vcf.gz Sample.list Pos.list
##	cp Pathogenic.All.trans.split $prefix\.burden.detail
##	add_total_case.pl -n 4,5 -g21 $prefix\.burden.detail $prefix\.burden.allfisher.tmp | sort -k17,17g | awk '$17!="NA"' > $prefix\.burden.allfisher.forexcel
##fi
##sort -k13,13g $prefix\.burden.allfisher.brown.method  | awk '$13 !="NA"' | head -n 1000 | tee Top1000 | fetch.pl -h -q1 -d21 - $prefix\.burden.detail  > $prefix\.burden.top1000.detail
##grep -v multichr ped.burden.allfisher.forexcel |awk '$20>=1' > variant.forexcel
##grep  -E 'Gene|multichr' ped.burden.allfisher.forexcel > pathway.forexcel
##
### Clean up
##rm -rf DetailGT
##mkdir DetailGT
##mv $prefix\.burden.all FMD.norm.PASS.0.98.sel.vcf.gz Pathogenic.All.trans Pathogenic.All.trans.split header err Sample.list pos.list* *.tmp DetailGT
##
