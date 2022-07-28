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

## Reading in results from phenotype groups: MAS, RAS, NF1, Aneurysm
## THis is the DEG analysis results
#### Run GSEA results for different groups ####
load("TissueSpecific_AnalysisResult_V1.RData") # load resAn, resMAS, resNF, resRAS
dataList <- list(#NF1Aorta = resNF1Aorta,
                 NF1Renal = resNF1Renal,
                 TRIM67Renal = resTRIM67Renal,
                 WSRenal = resWSRenal
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
permutation <- rankStats(resNF1Renal)
permutation2 <- rankStats(resNF1Renal)
set.seed(1234)
random_index <- order(runif(n=nrow(resNF1Renal)))
names(permutation) = resNF1Renal$symbol[random_index]
set.seed(123456)
random_index2 <- order(runif(n=nrow(resNF1Renal)))
names(permutation2) = resNF1Renal$symbol[random_index2]

statsList <- list(#NF1Aorta = rankStats(resNF1Aorta),
                  NF1Renal = rankStats(resNF1Renal),
                  TRIM67Renal = rankStats(resTRIM67Renal),
                  WSRenal = rankStats(resWSRenal),
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

######################## MAPK pathways from curated pathways, selected #####
groups <- names(gseaGO)
setwd("MAPK_Plots")
for (i in 1:length(groups)){
  pathwaysMAPK <- as.data.frame(gseaGO[[i]][grep("MAPK", pathway)])
  #pathwaysMAPK <- pathwaysMAPK[grep("PATHWAY$",pathwaysMAPK$pathway),]
  pathwaysMAPK <- pathwaysMAPK[grep("P38",pathwaysMAPK$pathway,invert = T),]
  pathwaysMAPK <- pathwaysMAPK[grep("BARR",pathwaysMAPK$pathway,invert = T),]
  pathwaysMAPK <- pathwaysMAPK[grep("MAPKKK",pathwaysMAPK$pathway,invert = T),]
  pathwaysMAPK <- pathwaysMAPK[grep("MAPKK",pathwaysMAPK$pathway,invert = T),]
  pathwaysMAPK <- pathwaysMAPK[grep("WNT",pathwaysMAPK$pathway,invert = T),]
  
  colnames(pathwaysMAPK)
  pathwaysMAPK$pathway
  pathwaysMAPK <- pathwaysMAPK[order(pathwaysMAPK$pathway, decreasing=FALSE),] ##Order by pvalue
  
  p1 <- ggplot(pathwaysMAPK, aes(color=NES, y=pathway, cex=size, x=padj)) +
    #p1 <- ggplot(pathwaysMAPK, aes(color=NES, y=reorder(pathway,desc(pval)), cex=size, x=padj)) +
    ylab("MAPK-related Curated Pathways") +
    xlab("FDR") +
    labs(title = paste0("GO MAPK pathway enrichment ",groups[i])) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    geom_segment(aes(x = 0.1, y = nrow(pathwaysMAPK), xend = 0, yend = nrow(pathwaysMAPK)),
                 arrow = arrow(), cex=0, color="darkgreen") +
    #annotate("text", x=0.18, y=nrow(pathwaysMAPK), label= "significant\n pathways", color="darkgreen") +
    #annotate("text", x=1, y=5, label= "down NF1", color="darkorange") +
    #annotate("text", x=1, y=6, label= "up NF1", color="blue") +
    coord_cartesian(clip="off") +
    xlim(0,1) + 
    theme(axis.text=element_text(size=12))
  p1
  ggsave(paste0("MAPK_",groups[i],".png"), width = 11, height = 6.5)
}

######################## Get results for upstream and downstream pathways for MAPK #####
groups <- names(gseaGO)
setwd("MAPK_Plots")
for (i in 1:length(groups)){
  #pathwaysMAPK <- as.data.frame(gseaGO[[i]][grep(pattern='EPIDERMAL_GROWTH_FACTOR|RAS_|MAPKKK|MAPKK|ERK1', pathway)])
  pathwaysMAPK <- as.data.frame(gseaGO[[i]][grep(pattern='RAS_|ERK1', pathway)])
  colnames(pathwaysMAPK)
  pathwaysMAPK$pathway
  pathwaysMAPK <- pathwaysMAPK[order(pathwaysMAPK$pathway, decreasing=FALSE),] ##Order by pvalue
  
  p1 <- ggplot(pathwaysMAPK, aes(color=NES, y=pathway, cex=size, x=padj)) +
    #p1 <- ggplot(pathwaysMAPK, aes(color=NES, y=reorder(pathway,desc(pval)), cex=size, x=padj)) +
    ylab("MAPK-related Curated Pathways") +
    xlab("FDR") +
    labs(title = paste0("GO MAPK up and downstream ",groups[i])) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    geom_segment(aes(x = 0.1, y = nrow(pathwaysMAPK), xend = 0, yend = nrow(pathwaysMAPK)),
                 arrow = arrow(), cex=0, color="darkgreen") +
    #annotate("text", x=0.18, y=nrow(pathwaysMAPK), label= "significant\n pathways", color="darkgreen") +
    #annotate("text", x=1, y=5, label= "down NF1", color="darkorange") +
    #annotate("text", x=1, y=6, label= "up NF1", color="blue") +
    coord_cartesian(clip="off") +
    xlim(0,1) + 
    theme(axis.text=element_text(size=12))
  p1
  ggsave(paste0("Up_Down_MAPK_",groups[i],".png"), width = 11, height = 6.5)
}

######################## Get results PI3K pathways, another regulations of MAPK #####
groups <- names(gseaGO)
setwd("MAPK_Plots")
for (i in 1:length(groups)){
  #pathwaysMAPK <- as.data.frame(gseaGO[[i]][grep(pattern='EPIDERMAL_GROWTH_FACTOR|RAS_|MAPKKK|MAPKK|ERK1', pathway)])
  #pathwaysMAPK <- as.data.frame(gseaGO[[i]][grep(pattern='RAS_|ERK1', pathway)])
  pathwaysMAPK <- as.data.frame(gseaGO[[i]][grep(pattern='PHOSPHATIDYLINOSITOL_3_KINASE', gseaGO[[i]]$pathway)])
  pathwaysMAPK <- pathwaysMAPK[grep(pattern='GOBP', pathwaysMAPK$pathway),]
  colnames(pathwaysMAPK)
  pathwaysMAPK$pathway
  pathwaysMAPK <- pathwaysMAPK[order(pathwaysMAPK$pathway, decreasing=FALSE),] ##Order by pvalue
  
  p1 <- ggplot(pathwaysMAPK, aes(color=NES, y=pathway, cex=size, x=padj)) +
    #p1 <- ggplot(pathwaysMAPK, aes(color=NES, y=reorder(pathway,desc(pval)), cex=size, x=padj)) +
    ylab("GO PI3K Curated Pathways") +
    xlab("FDR") +
    labs(title = paste0("GO PI3K  ",groups[i])) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    geom_segment(aes(x = 0.1, y = nrow(pathwaysMAPK), xend = 0, yend = nrow(pathwaysMAPK)),
                 arrow = arrow(), cex=0, color="darkgreen") +
    #annotate("text", x=0.18, y=nrow(pathwaysMAPK), label= "significant\n pathways", color="darkgreen") +
    #annotate("text", x=1, y=5, label= "down NF1", color="darkorange") +
    #annotate("text", x=1, y=6, label= "up NF1", color="blue") +
    coord_cartesian(clip="off") +
    xlim(0,1) + 
    theme(axis.text=element_text(size=12))
  p1
  ggsave(paste0("PI3K",groups[i],".png"), width = 11, height = 6.5)
}

########## Get the gene list for DAVID test ########## 
dataPadj <- list()
groups <- names(dataList)
padj_thr <- 0.05
setwd("../ForDavid")

for (i in 1:length(groups)){
  sel <- dataList[[i]]
  sel <- sel[sel$padj<= padj_thr,]
  sel <- sel[!is.na(sel$pad),]
  sel <- sel[order(sel$foldchange, decreasing = TRUE),]
  sel$downGeneNum <- sum(sel$foldchange<=1, na.rm=T)
  sel$upGeneNum <- sum(sel$foldchange>=1, na.rm=T)
  sel$totalGeneNum <- nrow(sel)
  dataPadj <- append(dataPadj, list(a=sel))
  # write gene list for DAVID
  write.table(sel$symbol[sel$foldchange>=1], 
              file = paste0(groups[i],"_up.txt"), row.names=F, col.names =F, quote =F)
  write.table(sel$symbol[sel$foldchange<=1], 
              file = paste0(groups[i],"_down.txt"), row.names=F, col.names =F, quote =F)
  write.table(sel$symbol, 
              file = paste0(groups[i],"_All.txt"), row.names=F, col.names =F, quote =F)
}

names(dataPadj) <- groups
setwd("../")
write_xlsx(dataPadj, "PedsCelllineRNASeq_DEG_TissueSpecific_V1_Padj0.05.xlsx")

########## Get the gene list for GSEA test ########## 

setwd("ForGSEA")
groups <- names(dataList)
for (i in 1:length(groups)){
  sel <- dataList[[i]]
  sel <- sel[order(sel$stat,decreasing = T), ]
  sel <- sel[!is.na(sel$hgnc_symbol),]
  sel <- sel[sel$hgnc_symbol!="",]
  output <- cbind(sel$hgnc_symbol, sel$stat)
  colnames(output) <- c("GeneName","Rank")
  write.table(output, 
              file = paste0(groups[i],"_GSEA.rnk"), row.names = F, col.names = T,sep="\t", quote = F)
}
