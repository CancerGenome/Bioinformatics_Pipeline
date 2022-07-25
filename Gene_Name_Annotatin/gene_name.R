#!/usr/bin/env Rscript

#########################################################################
#      USAGE: gene_name.R Input
#      Description: Format of Input: TP53
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Mon 25 Jul 2022 04:03:16 PM EDT
#########################################################################

## Input
args <- commandArgs(trailingOnly = TRUE)
## Database 
gene_name <- read.table("db/gene_name",header=T)
omim <- read.table("db/omim.gene.txt", header=T)

## Merge Gene name, OMIM, and GeneCard and Others
gene <- read.table(paste(args[1]) )
gene <- cbind(gene, data.frame(1:nrow(gene)))
colnames(gene) = c("V1","V2")

merge <- merge(gene_name, gene, by.x="Symbol",by.y="V1",all.x=F, all.y=T)
merge <- merge(omim,merge, by.x="Symbol",by.y="Symbol",all.x=F, all.y=T)
merge <- merge[order(merge$V2),]
merge$GeneCardLink = paste("https://www.genecards.org/cgi-bin/carddisp.pl?gene=",merge$Symbol,sep="")
merge$OMIMLink = ifelse(merge$OMIM=="NA","NA",paste("https://www.omim.org/entry/",merge$OMIM,"?highlight=",merge$Symbol,sep=""))

## Detailed Version
write.csv(merge[,c(1,2,3,4,5,6,8,9)], file= paste0(args[1],".gene.name.csv"),quote=F, row.names=F)
print(paste0("Detailed Version Output: ",args[1],".gene.name.csv"))

## Lite Version
sel <- merge[,c("Symbol","OMIM","description","GeneCardLink","OMIMLink")]
write.csv(sel, file= paste0(args[1],".gene.name.lite.csv"),quote=F, row.names=F)
print(paste0("Lite Version Output: ",args[1],".gene.name.lite.csv"))
