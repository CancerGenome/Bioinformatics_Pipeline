#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: Run_BurdenTest_fromPathoVar.sh <Prefix> <Input List_Full Path>  <PED File_Full Path>
#      Description: 
#      All Path should be full path
#
#      Full Path Input List, this is the variant list
#      The 1-5 column should be: CHROM POS REF ALT Gene_Name 
#
#      group.vcf.gz: are all PASS with 98% rate, could also use origianl files, 
#      but smaller group.vcf.gz will enhance the speed.
#
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Sat 09 Nov 2019 09:26:52 AM EST
#########################################################################
"
exit
fi
prefix=$1
input=$2;
ped=$3
#cd $prefix
:<<'BLOCK'
BLOCK
rm -rf $prefix
mkdir $prefix;
cd $prefix
rm -rf collapse wcnt madsen VT skat 
mkdir collapse wcnt madsen VT skat 

## Prepare the group file, group.vcf.gz file
cp $input sel # sel is the variant select
cp $ped $prefix\.ped # this is the ped file
sed '1d' sel | prepare_groupV2.pl -c 5 - | add_pathway_to_groupfile.pl ~/bin/fmd.pathway.gene.list - > group.file # first prepare the group file, then add the existing pathway for them
cut -f1-2 sel | sed '1d' | bcftools view -f PASS -i 'AN>=1317' --threads 1 -c1 -T - -Oz -o FMD.norm.PASS.0.98.sel.vcf.gz ~/FMD/anno/FMD.norm.vcf.gz.hg19_annovar.vcf.gz
bcftools sort -Oz -o group.vcf.gz FMD.norm.PASS.0.98.sel.vcf.gz 
bcftools index -t group.vcf.gz

epacts group -vcf group.vcf.gz  -ped $prefix\.ped -out collapse/collapse -test b.collapse -groupf group.file  --pheno disease   --cov C1 --cov C2 --cov SEX --run 4
epacts group -vcf group.vcf.gz  -ped $prefix\.ped -out wcnt/wcnt -test b.wcnt -groupf group.file  --pheno disease   --cov C1 --cov C2 --cov SEX --run 4
epacts group -vcf group.vcf.gz  -ped $prefix\.ped -out madsen/madsen -test b.madsen -groupf group.file  --pheno disease   --cov C1 --cov C2 --cov SEX --run 4
epacts group -vcf group.vcf.gz  -ped $prefix\.ped -out skat/skat -test skat -skat-o -groupf group.file  --pheno disease   --cov C1 --cov C2 --cov SEX --run 4
epacts group -vcf group.vcf.gz  -ped $prefix\.ped -out VT/VT -test VT -groupf group.file  --pheno disease   --cov C1 --cov C2 --cov SEX --run 4
# First combine
combine_epacts_gene_name_V3.pl - >  $prefix\.burden.all
Rscript ../sh/Brown_Fisher_Method.R $prefix\.burden.all

# Second prepare for output excel, and variant details
sed '1d' $prefix\.ped | cut -f1 > sample.list
sed '1d' sel | cut -f1-4 > pos.list.all
Format_Brown_ResultV2.pl $prefix\.burden.allfisher.brown.method > $prefix\.burden.allfisher.tmp

if [[ $prefix == "ped"* ]]; then
	PathogenicV4_pipeline_forBurdenTestV15_Ped.sh group.vcf.gz sample.list pos.list.all
	cp Pathogenic.All.trans.split $prefix\.burden.detail
	add_total_case.pl -n 3,5 -g21 $prefix\.burden.detail $prefix\.burden.allfisher.tmp > $prefix\.burden.allfisher.forexcel
elif [[ $prefix == "adult"* ]]; then
	PathogenicV4_pipeline_forBurdenTestV15_Adult.sh group.vcf.gz sample.list pos.list.all
	cp Pathogenic.All.trans.split $prefix\.burden.detail
	add_total_case.pl -n 4,5 -g21 $prefix\.burden.detail $prefix\.burden.allfisher.tmp > $prefix\.burden.allfisher.forexcel
fi

sort -k13,13g $prefix\.burden.allfisher.brown.method  | awk '$13 !="NA"' | head -n 1000 | fetch.pl -h -q1 -d21 - $prefix\.burden.detail  > $prefix\.burden.detail.top1000

# Get detailed phenotypes for gene with pvalue <= 1e-2
# awk '$NF~/P/ || $NF<=1e-2'  $prefix\.burden.all | sort -k12,12g > $prefix\.burden.1e-2
# cat group.file| fetch.pl -q1 -d1 $prefix\.burden.1e-2 - |  cut -f2- | GapTrans -tn - | sed 's/:/\t/;s/_/\t/;s/\//\t/'| sort -k1V,1 -k2n,2 -k3,3 -k4,4 | uniq > pos.list
#PathogenicV4_pipeline.sh group.vcf.gz sample.list pos.list
#cp Pathogenic.All.trans.split $prefix\.burden.1e-2.detail

# Clean up
rm -rf DetailGT
mkdir DetailGT
mv $prefix\.burden.all *.1e-2* FMD.norm.PASS.0.98.sel.vcf.gz Pathogenic.All.trans Pathogenic.All.trans.split header err sample.list pos.list* *.tmp DetailGT
