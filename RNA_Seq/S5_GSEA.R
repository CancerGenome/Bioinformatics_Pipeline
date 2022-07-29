#### load libraries ####
library(fgsea)
library(plyr)
library(readxl)
library(writexl)
library(ggplot2)
library(RColorBrewer)
library(pheatmap)
source("~/bin/Functions_forDESeq.R")

setwd("/nfs/turbo/umms-sganesh-secure/yulywang/FMD/RNASeq/Ped_Cellline_RNA/DEG_analysis")
list.files()

#### Read in gene set files (from MSigDB), use latested V7.4 ####
## include GO, KEGG, HallMark, CellTypeMarker, and Phenotypes for human

geneSetGO <- gmtPathways("../../Ped_Tissue_RNASeq/DEG_analysis/GSEA/v7.4/c5.go.v7.4.symbols.1000genes.filter.gmt") # remove those large geneset
## Remove extremely long genes list
geneSetGO <- geneSetGO[lengths(geneSetGO)<=1000]

## THis is the DEG analysis results
#### Run GSEA results for different groups ####
load("TissueSpecific_AnalysisResult_V1.RData") 
dataList <- list(
                 G1Renal = resG1Renal,
                 G2Renal = resG2Renal,
                 G3Renal = resG3Renal
)

# Run GSEA with all genes ranks.
rankStats <- function(x){
  y <- as.numeric(x$stat[order(x$stat, decreasing = TRUE)])
  names(y) <- x$symbol[order(x$stat, decreasing = TRUE)]
  return(y)
}

rmDups <- function(statsList){
  for(i in 1:length(statsList)){
    statsList[[i]] <- subset(statsList[[i]], !(duplicated(names(statsList[[i]]))))
  }
  return(statsList)
}

# generate a randomize geneset for test 
permutation <- rankStats(resG1Renal)
permutation2 <- rankStats(resG1Renal)
set.seed(1234)
random_index <- order(runif(n=nrow(resG1Renal)))
names(permutation) = resG1Renal$symbol[random_index]
set.seed(123456)
random_index2 <- order(runif(n=nrow(resG1Renal)))
names(permutation2) = resG1Renal$symbol[random_index2]

statsList <- list(
                  G1Renal = rankStats(resG1Renal),
                  G2Renal = rankStats(resG2Renal),
                  G3Renal = rankStats(resG3Renal),
                  Perm = permutation,
                  Perm2 = permutation2
                 
)

statsList <- rmDups(statsList)

#### Run all GSEA GO enrichment test ####
gseaGO <- list()
gseaGO_padj0.05 <- list()

for(i in 1:length(statsList)){
  gseaGO[[i]] <- fgsea(stats = statsList[[i]], pathways = geneSetGO, nperm = 1000, minSize = 3)
  gseaGO[[i]]$leadingEdge <- vapply(gseaGO[[i]]$leadingEdge, paste, collapse=",", character(1L)) #collapse leading edge so that it
  names(gseaGO)[i] <- paste("GO", names(statsList[i]), sep="_") #rename each df after relevant phen group
  
  gseaGO_padj0.05[[i]] <- gseaGO[[i]][gseaGO[[i]]$padj<=0.05,]
  names(gseaGO_padj0.05)[i] <- paste("GO", names(statsList[i]), sep="_") #rename each df after relevant phen group
}

save(gseaGO, file = "PedsCelllineRNASeq_GSEAresult_TissueSpecific_All_YW.RData")
write_xlsx(gseaGO_padj0.05, "PedsCelllineRNASeq_GSEAresult_TissueSpecific_All_YW.RData_Padj0.05.xlsx")
