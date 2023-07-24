#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Run_BurdenTest_fromPathoVarV16_CombineSingle.sh <Prefix> <VCF>
#      Description:
#      This is a sub module for ~/bin/Run_BurdenTest_fromPathoVarV16.sh
#      For any single variant association, we will provide
#      This pipeline will export variant (BrowP<=0.1), all pathways, Top1000 Gene details
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 10 Apr 2020 04:21:36 PM EDT
#########################################################################
"
exit
fi
#VCF='/home/yulywang/FMD/anno/Ped.EUR.afterQC.vcf.gz'
prefix=$1
VCF=`readlink -f $2`

# Combine Variants together
combine_epacts_singleV2.pl - | sort -k14g,14 >  $prefix\.single.combine
prepare_for_annovar.pl $prefix\.single.combine | sort -k1V,1 -k2n,2 > for_annovar
annovar_vcf for_annovar
GapTrans -tr for_annovar.hg19_multianno.txt  | cut -f1-21,27,35,39,45,48,54,56,57,58,60,64,66,97,99,125-128,157- > cache;
fetch.pl -h -ar -pq1 -d55  $prefix\.single.combine cache | sort -k14g,14 > $prefix\.single.combine.forexcel
mkdir annovar_single
mv cache for_annovar* annovar_single
######----- Predicted Deleterious For Single Test ------ #####
echo "Predicted Deleterious For Single Test Done"

########### Archive
#mkdir $DIR/Deleterious_Single
#cd $DIR/Deleterious_Single
#cp $ped .
#rm -rf wald score 
#mkdir wald score 
#
#echo "Using $Sel_VCF for analysis"
#epacts single --vcf $Sel_VCF --ped $ped --test b.wald --out wald/b.wald --run 4 --pheno disease  --cov C1 --cov C2 --cov SEX
#epacts single --vcf $Sel_VCF --ped $ped --test b.score --out score/b.score --run 4 --pheno disease  --cov C1 --cov C2 --cov SEX
#epacts single --vcf /home/yulywang/FMD/BurdenTest/V16/ped/group.vcf.gz --ped $ped --test b.wald --out wald/b.wald --run 4 --pheno disease  --cov C1 --cov C2 --cov SEX
#epacts single --vcf /home/yulywang/FMD/BurdenTest/V16/ped/group.vcf.gz --ped $ped --test b.score --out score/b.score --run 4 --pheno disease  --cov C1 --cov C2 --cov SEX

