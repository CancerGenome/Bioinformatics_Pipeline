#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: Run_BurdenTest_fromPathoVar.sh <Prefix> <VCF File> <PED File> <More Covar>
#      Design for permutation purpose, 
#      given a ped file, will randomize the ped file first. 
#      Description: 
#         Covar Default: use gender, PC1, PC2
#             Otherwise: "Age" will use Age as additional covar
#                        "BATCH" will use BATCH as additional covar
#      Different with Burden test pipeline, only calculate test, do not combine them together, no SKAT
#
#      Full Path Input List, this is the variant list
#      The 1-5 column should be: CHROM POS REF ALT Gene_Name 
#      Given VCF and PED file, will run following test:
#      1. Traditional burden test, five test: wcnt, skat-o, VT, madsen, and etc
#      2. Single association test for all: wald and score
#      3. Burden test with deleterious variants only. See pipeline from PathogenicV4_pipeline_forBurdenTestV15_Ped.sh PathogenicV4_pipeline_forBurdenTestV15_Adult.sh
#      Mask Annotation if you want to run several tasks at one time
#TODO signle MAF criteria
#      group.vcf.gz: are all PASS with 98% rate, could also use origianl files, 
#      but smaller group.vcf.gz will enhance the speed.
#
#      Check the final result: find . -name *.epacts |xargs ls -lh, check file size
#                              ls */*.forexcel and check filesize, making sure the size is 100K or M
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Sat 09 Nov 2019 09:26:52 AM EST
#########################################################################
"
#      -a: adding BATCH as one covariance, default: no BATCH effect
#      -b: adding Age as one covariance, default: no Age effect
#      CAVEAT: -a -b should be the last arguments
exit
fi
prefix=$1;
VCF=`readlink -f $2`;
ped=`readlink -f $3`;
COVAR=$4;
SECONDS=0

# option for adding cov or not
cmd='--cov C1 --cov C2 --cov SEX --run 4'
if [[ $COVAR == "Age"* ]]; then
	cmd='--cov C1 --cov C2 --cov SEX --cov Age --run 4'
	echo "Add Age as one covar"
elif [[ $COVAR == "BATCH"* ]]; then
	cmd='--cov C1 --cov C2 --cov SEX --cov BATCH --run 4'
	echo "Add BATCH as one covar"
else 
	cmd='--cov C1 --cov C2 --cov SEX --run 4'
	echo "Using default covar"
fi

#cd $prefix
:<<'BLOCK'
BLOCK

rm -rf $prefix;
mkdir $prefix;
cd $prefix;
Rscript ~/bin/Permutate_Ped.R $ped
ped=`readlink -f permutation.ped`;

DIR=`pwd`
mkdir Deleterious
cd Deleterious
cp $ped $prefix\.ped # this is the ped file

awk '{print $1}' $ped | sed '1d' > Sample.list
## Prepare Deleterious Variants and VCF file here
if [[ $prefix == "ped"* ]]; then
	PathogenicV4_pipeline_forBurdenTestV15_Ped.sh $VCF Sample.list
	cut -f12-15,21 Pathogenic.All.trans.split | uniq | awk '$1!="X" && $1!="Y" && $1!="MT" ' | uniq > sel # sel is the variant select
elif [[ $prefix == "adult"* ]]; then
	PathogenicV4_pipeline_forBurdenTestV15_Adult.sh $VCF Sample.list
	cut -f12-15,21 Pathogenic.All.trans.split | uniq | awk '$1!="X" && $1!="Y" && $1!="MT" ' | uniq > sel # sel is the variant select
fi

sed '1d' sel | prepare_groupV2.pl -c 5 - | add_pathway_to_groupfile.pl ~/bin/fmd.pathway.gene.list - > group.file # first prepare the group file, then add the existing pathway for them
cut -f1-2 sel | sed '1d' | bcftools view -f PASS --threads 2  -i 'F_MISSING<=0.02' -c1 -T - -Oz -o FMD.norm.PASS.0.98.sel.vcf.gz $VCF 
bcftools sort -Oz -o group.vcf.gz FMD.norm.PASS.0.98.sel.vcf.gz 
bcftools index -t group.vcf.gz
Sel_VCF=`readlink -f group.vcf.gz`;
echo "Predict Deleterious VCF Prepared"

###### Section I
######----- Predicted Deleterious Burden Test ------ #####
rm -rf collapse wcnt madsen VT skat 
mkdir collapse wcnt madsen VT skat 

epacts group -vcf $Sel_VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file  --pheno disease $cmd
epacts group -vcf $Sel_VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file  --pheno disease  $cmd 
epacts group -vcf $Sel_VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file  --pheno disease   $cmd
#epacts group -vcf $Sel_VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file  --pheno disease   $cmd
epacts group -vcf $Sel_VCF  -ped $ped -out VT/VT -test VT -groupf group.file  --pheno disease   $cmd

# First combine Deleterious Variant First
combine_epacts_gene_name_V3.pl - >  $prefix\.burden.all

rm Pathogenic.All.trans*
rm FMD.norm.PASS.0.98.sel.vcf.gz
######----- Predicted Deleterious Burden Test ------ #####
echo "Predicted Deleterious Burden Test Done"

###### Section II
######----- Predicted Deleterious For Single Test ------ #####
mkdir $DIR/Deleterious_Single
cd $DIR/Deleterious_Single
cp $ped .
rm -rf wald score 
mkdir wald score 

echo "Using $Sel_VCF for analysis"
epacts single --vcf $Sel_VCF --ped $ped --test b.wald --out wald/b.wald --pheno disease  $cmd
epacts single --vcf $Sel_VCF --ped $ped --test b.score --out score/b.score --pheno disease $cmd

rm $DIR/Deleterious/group.vcf.gz*

######----- Predicted Deleterious For Single Test ------ #####
echo "Predicted Deleterious For Single Test Done"

######----- Burden Test Traditionally LOF0.01/0.05 LOF_nonsyn 0.01/0.05------ #####
mkdir $DIR/All
cd $DIR/All
mkdir LOF_0.01 LOF_0.05 LOF_Nonsyn_0.01 LOF_Nonsyn_0.05
cp $ped $prefix\.ped

FILE=$VCF\.epacts.vcf.gz
if [ -f "$FILE" ]; then
	    echo "$FILE exist"
else 
		echo "$FILE does not exist"
		epacts anno -db gencodeV19 -in $VCF -out $VCF\.epacts.vcf.gz # will mute once have this annotation file
		bcftools index -t $VCF\.epacts.vcf.gz
fi

ORIGINAL_VCF=$VCF
VCF=$VCF\.epacts.vcf.gz

cd $DIR/All/LOF_0.01
rm -rf collapse wcnt madsen VT skat 
mkdir collapse wcnt madsen VT skat 
echo "Using $VCF for analysis"
epacts make-group -vcf $VCF -out group.file.cache --format epacts  -type Essential_Splice_Site -type Start_Loss -type Stop_Gain -type Stop_Loss --type Frameshift --type CodonGain --type CodonLoss -pass
add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
epacts group -vcf $VCF -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.01 --pheno disease   $cmd
epacts group -vcf $VCF -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.01 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.01 --pheno disease   $cmd
#epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file -max-maf 0.01 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file -max-maf 0.01 --pheno disease   $cmd

cd $DIR/All/LOF_0.05
rm -rf collapse wcnt madsen VT skat 
mkdir collapse wcnt madsen VT skat 
epacts make-group -vcf $VCF -out group.file.cache --format epacts  -type Essential_Splice_Site -type Start_Loss -type Stop_Gain -type Stop_Loss --type Frameshift --type CodonGain --type CodonLoss -pass
add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
epacts group -vcf $VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.05 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.05 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.05 --pheno disease   $cmd
#epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file -max-maf 0.05 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file --pheno disease   $cmd

cd $DIR/All/LOF_Nonsyn_0.01
rm -rf collapse wcnt madsen VT skat
mkdir collapse wcnt madsen VT skat
epacts make-group -vcf $VCF -out group.file.cache --format epacts  -type Essential_Splice_Site -type Start_Loss -type Stop_Gain -type Stop_Loss --type Frameshift --type CodonGain --type CodonLoss --type Nonsynonymous -pass
add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
epacts group -vcf $VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.01 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.01 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.01 --pheno disease   $cmd
#epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file -max-maf 0.01 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file -max-maf 0.01 --pheno disease   $cmd

cd $DIR/All/LOF_Nonsyn_0.05
rm -rf collapse wcnt madsen VT skat
mkdir collapse wcnt madsen VT skat
epacts make-group -vcf $VCF -out group.file.cache --format epacts  -type Essential_Splice_Site -type Start_Loss -type Stop_Gain -type Stop_Loss --type Frameshift --type CodonGain --type CodonLoss --type Nonsynonymous -pass
add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
epacts group -vcf $VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.05 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.05 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.05 --pheno disease   $cmd
#epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o  -groupf group.file -max-maf 0.05 --pheno disease   $cmd
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file --pheno disease   $cmd

## Combine files
VCF=$ORIGINAL_VCF # change back to no epacts result
cd $DIR/All
#Run_BurdenTestV16.CombineTraditionalBurdenTest.sh $prefix $VCF
######----- Burden Test Traditionally LOF0.01/0.05 LOF_nonsyn 0.01/0.05------ #####
echo "Burden Test Traditionally LOF0.01/0.05 LOF_nonsyn 0.01/0.05 Done"

######----- Traditionally Single Test ------ #####
mkdir $DIR/All_Single
cd $DIR/All_Single
rm -rf wald score 
mkdir wald score 

epacts single --vcf $VCF --ped $ped --test b.wald --out wald/b.wald --pheno disease  $cmd
epacts single --vcf $VCF --ped $ped --test b.score --out score/b.score --pheno disease  $cmd

# Combine Variants together
#Run_BurdenTestV16.CombineSingle.sh $prefix $VCF
echo "Traditionally Single Test Done"
######----- Traditionally Single Test ------ #####

######----- Syn Burden Test ------ #####
cd $DIR
Run_BurdenTestV16.Syn.burden.sh $prefix $VCF $ped $COVAR
echo "Traditionally Synonymous Burden Test Done"

echo "All done"
duration=$SECONDS
echo "$duration seconds elapsed."
