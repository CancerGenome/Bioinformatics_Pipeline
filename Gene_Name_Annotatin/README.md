## Introduction

Given a list of gene, annotate them with following columns
> Symbol,OMIM,Type,EntrezeID,Ensemble,description,GeneCardLink,OMIMLink

## Usage

In a Linux Environment: 
> Rscript gene_name.R example.list

In a Rstudio Enrironment: replace this command: 
> args <- commandArgs(trailingOnly = TRUE)

with 

> args <- ("Your_FileName")

## Output

Detailed Version Output: All columns listed above

Lite Version Output: Selected columns from detailed version

## Caveat

Be sure the gene name is standard approved official symbols, to check them: 
https://www.genenames.org/

## Files in the db folder

- omim.gene.txt: 
Originallly download from OMIM: https://www.omim.org/static/omim/data/mim2gene.txt

Command line to process this file

> wget https://www.omim.org/static/omim/data/mim2gene.txt

> awk '$2=="gene"' mim2gene.txt | awk '!a[$4]++' | awk 'BEGIN{print "OMIM\tType\tEntrezeID\tSymbol\tEnsemble"}{print $0}'> omim.gene.txt

- gene_name: 
Originally download from NCBI: https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz

Unzip the file and cut only Gene and description 

If you want to update both files, make sure the file names and header are identical with previous version

