## Introduction

Given a variant file (VCF) for multiple samples, identifying the haplotype for each sample

## Step 1: Prepare your VCF file

Prepare your VCF files with all samples that are needed to be phased. Please be familiar with bcftools, which is used to manipulate the samples and variants in VCF file. 

If you have multiple VCF resources, for example one internal, one from 1000 genome, you need to merge them first. Also pay attention to the variant call rate after merging various VCF. It's best if all samples contains that variants. 

Make sure the VCF files contains only polymorphism, and exclude the rare variants. In the COL5A1 paper (https://www.ahajournals.org/doi/10.1161/ATVBAHA.119.313885), the frequency criteria for polymorphism was 0.1 and we included MGI samples for an accurate estimation of allele frequency.

## Step 2: Conver to fastPhase format

Input Unzipped VCF file, output: OUTPUT.inp and OUTPUT.pos

> vcf2fastphase.pl INPUT.vcf OUTPUT.inp OUTPUT.pos Number_Total_Samples

## Step 3: Run FastPhase to phase the hayplotype

Install fastPhase and run with the OUTPUT.inp generated in the Step 2. The download page for fastPhase is: https://stephenslab.uchicago.edu/phase/download.html

> fastPHASE OUTPUT.inp

## Step 4: Convert fastPhase output to human readable fasta format

Input is fastPhase result, Output is fasta format

> fastPHASE2fa.pl fastphase_hapguess_switch.out > OUTPUT.fa

To compare different haplotype base by base, split them and import in Excel. 

> fa2excel.pl  OUTPUT.fa > OUTPUT.txt
