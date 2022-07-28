setwd("~/FMD/RNASeq/Ped_Cellline_RNA/DEG_analysis")

#### Install Packages ####

library(RColorBrewer)
library(gridExtra)
library(ggbiplot)
library(ggfortify)
library(biomaRt)
library(ggrepel)
library(DESeq2)
library(apeglm)
library(vsn)
library(plyr)
library(writexl)
source("~/bin/Functions_forDESeq.R")

#### Import dataset, here I am using the datasets from RSEM ####
data <- read.table("RSEM_transcript.genes.result")
tmp_data <- data
header = gsub("...RSEM.","",colnames(data))
header = gsub(".genes.results","", header)
header = gsub("X","", header)
colnames(data) = header
counts <- data

#### Prepare gene annotation throught Ensemble ####
annotation <- data.frame(ensemblvs = rownames(data))
annotation$ensembl <-  strtrim(annotation$ensemblvs, 15) #trimming to remove version number
ensemblids <- annotation$ensembl
ensembl<-useMart("ensembl", dataset="hsapiens_gene_ensembl", host = "useast.ensembl.org")

#test <- ensemblids[1:2000]
geneChrom<-getBM(attributes = c('ensembl_gene_id','entrezgene_id', ##Include entrez ID for enrichment analyses downstream
                                'hgnc_symbol','chromosome_name',"start_position","end_position", 'description','external_gene_name'),
                 filters = 'ensembl_gene_id', 
                 values = ensemblids, 
                 #values = test,
                 mart = ensembl)

colnames(geneChrom)[1] <- "ensembl"
annotation <- join(geneChrom, annotation, by="ensembl", type="right")

#### Read in sample phenotype and data processing ####

### Use updated sample info
sampledata <- read.csv("[Archive] Sample info for Ped Celline RNASeq - V1.csv", row.names = 1)
sampledata$ADnumber = sampledata$ID
str(sampledata)

sampledata$NF1 <- "other"
sampledata$NF1[sampledata$Priotized_gene=="NF1"] <- "NF1"
sampledata$NF1[grep("ADC",sampledata$ID)] <- "control"

sampledata$TRIM67 <- "other"
sampledata$TRIM67[sampledata$Priotized_gene=="TRIM67"] <- "TRIM67"
sampledata$TRIM67[grep("ADC",sampledata$ID)] <- "control"

sampledata$WS <- "other" # willian syndrom deletion
sampledata$WS[sampledata$Priotized_gene=="7q11.23"] <- "WS"
sampledata$WS[grep("ADC",sampledata$ID)] <- "control"

sampledata$NF1 <- as.factor(sampledata$NF1)
sampledata$TRIM67 <- as.factor(sampledata$TRIM67)
sampledata$WS <- as.factor(sampledata$WS)

#make sure controls are ref groups for all variables
levels(sampledata$NF1)
levels(sampledata$WS)
levels(sampledata$TRIM67)
#sampledata$An <- relevel(sampledata$An, ref = "control")

# Remove duplicated
sampledata[sampledata$RmDup=="Y",]
renalRM <- rownames(sampledata[sampledata$RmDup=="Y" & sampledata$tissue_group=="renal",])
aoRM <- rownames(sampledata[sampledata$RmDup=="Y" & sampledata$tissue_group=="aorta",])


#######################################################
####
#### Analysis plan ####
#### ##################################################

##### Filtering counts data ####
# Be consistent with what IB defined, 
# remove this when 9011_A is ready
sampledata_filter <- sampledata[rownames(sampledata) %in% colnames(counts),]
counts_filter <- counts[,rownames(sampledata)]
all(colnames(counts_filter) == rownames(sampledata_filter))

ind <- NULL
for(i in 1:length(counts_filter[,1])){
  x <- aggregate(t(counts_filter[i,]), by = list(sampledata_filter$tissue_group), mean)
  if(sum(x[,2] >= 1) > 1){ # at least two groups with >=1 counts
    ind[i] <- TRUE
  } else {
    ind[i] <- FALSE
  }
}

counts_filter <- counts_filter[ind,]

dim(counts_filter)
# 57820, 61, Before
# 19755, 79, After
## Save filtered file ##

write.table(round(counts_filter), file = "RSEM_transcript.genes.result.2Tissue1.filter", quote =F, sep="\t")

#Create DESeq object with all samples - use sample type as design for now

####### DESeq analysis ##########
dds <- DESeqDataSetFromMatrix(countData = round(counts_filter),
                              colData = sampledata_filter,
                              design = ~ID)

####creating new dds object with group variables - combine tissue info with phen group info
####and remove all duplicates samples

design(dds)

### Create new dds object with duplicate samples removed (see above for which samples)
ddsNoRep <- dds

###remove duplicate samples

#duplicate Ao samples, skip this step, no aoRM
#ddsNoRep <- ddsNoRep[,-c(which(colnames(ddsNoRep)%in%aoRM))] 

#duplicate Renal samples
ddsNoRep <- ddsNoRep[,-c(which(colnames(ddsNoRep)%in%renalRM))]
dim(ddsNoRep)
# [1] 19755    59

###Now create new group variables with phen and tissue info for analyses
#NF1
ddsNoRep$groupNF <- factor(paste(ddsNoRep$tissue_group, ddsNoRep$NF1, sep = "_"))
# TRIM67
ddsNoRep$groupTRIM67 <- factor(paste(ddsNoRep$tissue_group, ddsNoRep$TRIM67, sep ="_"))
# WS
ddsNoRep$groupWS <- factor(paste(ddsNoRep$tissue_group, ddsNoRep$WS, sep ="_"))

save(ddsNoRep,file="DESeqDataSet_backup.Rdata") # only for Dataset backup
# 1 Tissue specific NF1 DESeq model ########

#ddsNoRep$sex <- factor(ddsNoRep$sex)
annotation$symbol = annotation$hgnc_symbol

#### Caveat: use aorta as control ####
#resNF1Renal <- run_DESEQ(ddsNoRep, formula = c("~groupNF + lane + sex"), annotation,
resNF1Renal <- run_DESEQ(ddsNoRep, formula = c("~groupNF "), annotation, 
                         contrast = c("groupNF","renal_NF1","aorta_control") )

# 4 Tissue specific TRIM67 DESeq model ######## 
resTRIM67Renal <- run_DESEQ(ddsNoRep, formula = c("~groupTRIM67 "), annotation, 
                            contrast = c("groupTRIM67","renal_TRIM67","aorta_control") )

# 6 Tissue specific WS_ELN DESeq model ######## 
resWSRenal <- run_DESEQ(ddsNoRep, formula = c("~groupWS "), annotation, 
                            contrast = c("groupWS","renal_WS","aorta_control") )

save(#resNF1Aorta, resNF1Renal, 
  resNF1Renal,
  resTRIM67Renal,
  resWSRenal,
     file = "TissueSpecific_AnalysisResult_V1.RData")

sheets <- list("NF1Renal"=resNF1Renal,
               "TRIM67Renal"=resTRIM67Renal,
               "WSRenal"=resWSRenal
               )
write_xlsx(sheets, "PedsCelllineRNASeq_DEG_TissueSpecific_V1.xlsx")

##### Plot Vocalno Plot ####

filter = 10 # used for basemean filter
# by genetic data
r1 <- Volcano_YW(resNF1Renal, main = "NF1 Renal: 7 case vs 9 Aorta control",baseMeanFilter=filter) 
r2 <- Volcano_YW(resTRIM67Renal, main = "TRIM67 Renal: 3 case vs 9 Aorta control",baseMeanFilter=filter)
r3 <- Volcano_YW(resWSRenal, main = "WS Renal: 3 case vs 9 Aorta control",baseMeanFilter=filter) 
blank <- grid.rect(gp=gpar(col="white"))

pdf("TissueSpecific_VolcanoPlot_baseMeanFilter10_YW.pdf",width=16, height = 9)
#grid.arrange(a1,a2,a3,blank)
grid.arrange(r1,r2,r3,blank)
dev.off()

filter = 2 # used for basemean filter
# by genetic data
r1 <- Volcano_YW(resNF1Renal, main = "NF1 Renal: 7 case vs 9 Aorta control",baseMeanFilter=filter) 
r2 <- Volcano_YW(resTRIM67Renal, main = "TRIM67 Renal: 3 case vs 9 Aorta control",baseMeanFilter=filter)
r3 <- Volcano_YW(resWSRenal, main = "WS Renal: 3 case vs 9 Aorta control",baseMeanFilter=filter) 
blank <- grid.rect(gp=gpar(col="white"))
pdf("TissueSpecific_VolcanoPlot_baseMeanFilter2_YW.pdf",width=16, height = 9)
grid.arrange(r1,r2,r3,blank)
dev.off()
