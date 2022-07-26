## Introduction

Given a VCF file, annotate the VCF file with Annovar. 

Run envrioment: Linux

## Step 1: Download database from Annovar

After installing Annovar, please download database you prefer to annotate (https://annovar.openbioinformatics.org/en/latest/user-guide/download/). Specifically for all projects I have been working, hg19 is my preference. You may want to update this to hg38 or any new version of hg19. Please see more details of database I am using.

I have a copy of all dataset in Dataden. Please contact me if you really need my previous version of dataset. 

- refGene: refSeq
- ensGene: ensembleGene
- cytoBand
- genomicSuperDups
- snp129: dbsnp 129, the version without further large scale genome "containmination"
- avsnp150: may want to update this
- popfreq_all_20150413: may need to update
- gnomad_exome
- gnomad_genome
- UMD: personalized curated database from UMD-predictor
- dbnsfp35a: software prediction
- intervar_20180118: may need to update
- clinvar_20180603: may need to update

## Step 2: Run the Annotation

Input: VCF, Output: annotated VCF

Caveat: Annovar can handle several type of files, where we only discuss VCF here.

Please replace table_annovar.pl with the Full Path of your table_annovar.pl. Also replace the directory of your humandb from Annovar. 

> table_annovar.pl INPUT Dir_to_annovar_humandb_folder -buildver hg19 -out OUTPUT -remove -protocol refGene,ensGene,cytoBand,genomicSuperDups,snp129,avsnp150,popfreq_all_20150413,gnomad_exome,gnomad_genome,UMD,dbnsfp35a,intervar_20180118,clinvar_20180603 -operation g,g,r,r,f,f,f,f,f,f,f,f,f -nastring . -vcfinput 

## Step 3: Convert OUTPUT to human-readable file

Use bcftools to convert to human-readable file and export to excel

> bcftools view Annovar_Output.vcf | Annovar2Excel.sh - > OUTPUT.txt

## Step 4: A simple example

In the example folder, I copied the key scripts of Annovar and show you how to run a simple example

Go to db folder:

> unzip  hg19_refGeneMrna.fa.gz

> unzip hg19_refGene.txt.gz

Run this command line: 
>  ./table_annovar.pl example.vcf db/ -buildver hg19 -out output -remove -protocol refGene -operation g  -nastring . -vcfinput
