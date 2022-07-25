#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/Run_BurdenTestV16.syn.burden.combine.sh <PREFIX> <VCF> <PED file>
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 24 Apr 2020 04:28:13 PM EDT
#########################################################################
"
exit
fi

#####------ Start for Synonymous analysis, have four different levels: 0.01%, 0.1%, 1%, 5% ------
prefix=$1
VCF=`readlink -f $2`;
ped=`readlink -f $3`;
DIR=`pwd`;
mkdir $DIR/Syn
cd $DIR/Syn
mkdir Syn_0.0001 Syn_0.001 Syn_0.01 Syn_0.05
cp $ped $prefix\.ped
ORIGINAL_VCF=$VCF

:<<'BLOCK'
BLOCK

cd $DIR/Syn/Syn_0.0001
rm -rf collapse wcnt madsen VT skat 
mkdir collapse wcnt madsen VT skat 
echo "Using $VCF for analysis"
#epacts make-group -vcf $VCF -out group.file.cache --format epacts  -type Essential_Splice_Site -type Start_Loss -type Stop_Gain -type Stop_Loss --type Frameshift --type CodonGain --type CodonLoss -pass
#add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
bcftools view -i 'ExonicFunc.refGene=="synonymous_SNV" || ExonicFunc.ensGene == "synonymous_SNV"' $VCF | call_header4 - | awk '$24<=0.0001 && $25<=0.0001 && $26<=0.0001 && $27 <= 0.0001' | prepare_groupV2.pl -c10 - | add_pathway_to_groupfile.pl ~/bin/fmd.pathway.gene.list - > group.file
epacts group -vcf $VCF -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4

cd $DIR/Syn/Syn_0.001
rm -rf collapse wcnt madsen VT skat 
mkdir collapse wcnt madsen VT skat 
#epacts make-group -vcf $VCF -out group.file.cache --format epacts  -type Essential_Splice_Site -type Start_Loss -type Stop_Gain -type Stop_Loss --type Frameshift --type CodonGain --type CodonLoss -pass
#add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
bcftools view -i 'ExonicFunc.refGene=="synonymous_SNV" || ExonicFunc.ensGene == "synonymous_SNV"' $VCF | call_header4 - | awk '$24<=0.001 && $25<=0.001 && $26<=0.001 && $27 <= 0.001' | prepare_groupV2.pl -c10 - | add_pathway_to_groupfile.pl ~/bin/fmd.pathway.gene.list - > group.file 
epacts group -vcf $VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4

#### Apply epacts pipeline, because MAF >= 0.01 can be correctly estimated from lab samples
FILE=$VCF\.epacts.vcf.gz
if [ -f "$FILE" ]; then
	    echo "$FILE exist"
else 
		echo "$FILE does not exist"
		epacts anno -db gencodeV19 -in $VCF -out $VCF\.epacts.vcf.gz # will mute once have this annotation file
		bcftools index -t $VCF\.epacts.vcf.gz
fi

VCF=$VCF\.epacts.vcf.gz
cd $DIR/Syn/Syn_0.01
rm -rf collapse wcnt madsen VT skat
mkdir collapse wcnt madsen VT skat
epacts make-group -vcf $VCF -out group.file.cache --format epacts --type Synonymous -pass
add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
epacts group -vcf $VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file -max-maf 0.01 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4

cd $DIR/Syn/Syn_0.05
rm -rf collapse wcnt madsen VT skat
mkdir collapse wcnt madsen VT skat
epacts make-group -vcf $VCF -out group.file.cache --format epacts --type Synonymous -pass
add_pathway_to_groupfile.pl /home/yulywang/bin/fmd.pathway.gene.list group.file.cache > group.file 
epacts group -vcf $VCF  -ped $ped -out collapse/collapse -test b.collapse -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out wcnt/wcnt -test b.wcnt -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out madsen/madsen -test b.madsen -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out skat/skat -test skat -skat-o  -groupf group.file -max-maf 0.05 --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4
epacts group -vcf $VCF  -ped $ped -out VT/VT -test VT -groupf group.file --pheno disease   --cov C1 --cov C2 --cov SEX   --run 4

## Combine files
VCF=$ORIGINAL_VCF # change back to no epacts result
cd $DIR/Syn
Run_BurdenTestV16.CombineSyn.sh $prefix $VCF

#####------- Done for synonymous analysis ------ #####
