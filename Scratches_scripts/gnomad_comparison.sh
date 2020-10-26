#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: gnomad_comparison.sh <Gene> <AC_ForTest> <AN_ForTest>
#
#      Description: given a gene name, will output how many pathogenic variants in gnomad by format of 
#      AC_OwnSample AN_OwnSample AC_NFE, AN_NFE, AC_GnomadAll, AN_GnomadAll
#      where AC is the allele count, AN is the allele number, NFE is the non-finnish european
#      
#      Step 1 criteria: ~/bin/filter_pathoV4_CADD20.pl
#      Step 2 criteria: LOF+CADD>=20, gnomad should smaller than 0.01%
#      You may want to re_define your criteria by copying this script to your own directory
#
#      Output file: Pathogenic.gene.vcf.gz Gene.out
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 08 Nov 2019 10:02:36 PM EST
#########################################################################
"
exit
fi

gene=$1;
ac=$2;
an=$3;

mkdir $gene;
cd $gene;

:<<'BLOCK'
BLOCK
#---- Process gene and get position file
echo "Get gene and vcf file"
grep -w $gene ~/db/anno/hg19.map | cut -f1,2,4,5 |  sort -k1,1 -k2,2 -k3n,3 -k4n,4r | uniq |  awk '!a[$1]++'  | tee gene.list.detail | cut -f2-4 | sed 's/chr//' | sort -k1V,1 -k2n,2 -k3n,3 > gene.range
chr=`cut -f1 gene.range ` # get chr position
bcftools view -R gene.range /home/yulywang/FMD/TRAPD/gnomad/chr_QC/gnomad.exomes.r2.1.sites.chr$chr\.QD.DP.vcf.gz > gene.vcf
#----- Start Annovar
echo "Start Annovar"
annovar_vcf gene.vcf
rm gene.vcf.avinput
rm gene.vcf.hg19_multianno.txt
bgzip gene.vcf
bgzip gene.vcf.hg19_multianno.vcf
bcftools index gene.vcf.hg19_multianno.vcf.gz
#---- Step 1: Apply Starndard Criteria
echo "Create Pathogenic File by filter_pathoV4_CADD20.pl"
bcftools view -f "PASS" gene.vcf.hg19_multianno.vcf.gz | call_header4 - 2>err |  awk '!($25>0.001 || $27>0.001)' | cat ~/bin/header4 - | filter_pathoV4_CADD20.pl -m -  | bgzip > Pathogenic.All.gz 

#---- Step 2: Apply your own criteria here. by default  CADD>=20 + LOF , gnomad nfe 0.0001
echo "Personalize your own variant here"
bcftools view -h gene.vcf.hg19_multianno.vcf.gz > Pathogenic.gene.vcf # create header
bgzip -dc  Pathogenic.All.gz | awk '!($30>0.0001 || $32>0.0001)' | awk '$1+$5>=1' | cut -f6,7,8,9 | tee allele.list | cut -f1,2 > pos.list # this will restrict on only matched alleles
bcftools view -H -R pos.list gene.vcf.hg19_multianno.vcf.gz | fetch.pl -q1,2,3,4 -d1,2,4,5 allele.list - >>  Pathogenic.gene.vcf
bgzip Pathogenic.gene.vcf; 
bcftools index Pathogenic.gene.vcf.gz;
#---- Step 3: Statistics, you can skip this step 
bcftools query -f '%AC_nfe\t%AN_nfe\t%AC\t%AN\n' Pathogenic.gene.vcf.gz | awk -v gene="$gene" -v ac="$ac"  -v an="$an" 'BEGIN{OFS="\t"; print "Gene\tPed_AC\tPed_AN\tgnomad_NFE_AC\tgnomad_NFE_AN\tgnomad_AC\tgnomad_AN"} {a+=$1;c+=$3; if($2>b){b=$2}; if($4>d){d=$4}} END{print gene,ac,an,a,b,c,d}' > For_R

perl -e '{print "data <- read.table(\"For_R\",header = T)\n source(\"~/bin/R_declare.R\")\n data\$NFE_Fisher_Pvalue = apply(data[c(2,3,4,5)],1, calcfisher2)\n data\$All_Fisher_Pvalue = apply(data[c(2,3,6,7)],1, calcfisher2)\n write.table(file=\"Fisher_Pvalue.Output\", data, row.names = F, sep =\"\\t\", quote = F)\n "}' > Fisher_Pvalue.R
Rscript Fisher_Pvalue.R
