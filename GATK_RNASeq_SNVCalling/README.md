## Introduction

Call SNV from RNASeq data. Originally from GATK best practice

## Layout of your folder:
- Pipeline: for all your pipeline
- FASTQ: for all you raw FASTQ files and all following BAM files;
- CombineGVCF: temporay folder for CombineGVCF 
- GenotypeGVCF: temporay folder for GenotypeGVCF
- Final_VCF:  Final_VCF folder

## Prepare

Create new folder that are going to use. 

All useful scripts are located in src folder. Please include the full path src first OR export $PATH=$PATH:./src


## Step 1: Mapping with STAR

Please go to RNASeq folder for the mapping of STAR:

## Step 2, Mark Duplicaton with Picard

Run picard to label duplication.

> picard.sh TEST.sort.bam TEST

where TEST.sort.bam is sorted bam file generated by STAR, TEST is the prefix for all OUTPUT. Use BAM mapped to the whole genome, not the whole transcriptome.

### Step 3, SplitNCigar Reads Base Quality Recalibration and GVCF Infer

SplitNCigar is the specific procedure for RNASeq. Others are the same with DNA data. Please replace ref and --known-sites in GATK_SplitN_BQSR_GVCF.sh

> GATK_SplitN_BQSR_GVCF.sh YOUR_BAM PREFIX

where YOUR_BAM is the BAM generated by Picard and PREFIX is the PREFIX for the sample. 

## Caveat: Samples are not dependent for analysis above. For analysis below, you need to wait for all samples finished.

## Step 4 - 8 Combine GVCF, Merge Genotype, Hard Filtering and Annotation

After all samples have their own GVCF files, combine GVCF for each 30M, concat together, hard filtering for variants, and annotation. One command to run Step 4-8:

> ls *.g.vcf.gz > GVCF.list

> ./GATK_CombineGVCF_Merge_GenotypeGVCF_HardFilter_Annovar.pl -l GVCF.list > S5_8_CombineGVCF_Merge_GenotypeGVCF_HardFilter_Annovar.sh

> sh GATK_CombineGVCF_Merge_GenotypeGVCF_HardFilter_Annovar.sh

### Step 9 Concat all together.

Concat all together: 
> sh S9.Concat_after_Annovar.sh