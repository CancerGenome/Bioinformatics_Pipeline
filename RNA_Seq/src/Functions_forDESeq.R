# Volcano plot, need to polish the code
Volcano_YW <- function(input, n = 30, main = "DESeq", xlim=10, ylim=10, baseMeanFilter=0){
  ## Requriment
  ## Input should have a column called Gene_name, adj, log2FoldChange, 
  ## Gene_name is not the by default output for DESeq, should add this manuually
  ## Use Adjust Pvalue 0.1 to show differeent color
  ## By default highlight the top 30 genes; 
  ## Controled by Xlim, Will fold all log2FolderChange >=10 to 10, <=-10 to 10, 
  ## Controled by ylim, Will fold all padj <= 1E-10 to 1E-10
  
  # Input is the res from DESeq2
  # remove na, please see na reasons below
  NF1res <- input[!is.na(input$padj),]
  NF1res <- NF1res[NF1res$baseMean>= baseMeanFilter,]
  #Note on p-values set to NA: some values in the results table can be set to NA for one of the following reasons:
    
   # If within a row, all samples have zero counts, the baseMean column will be zero, and the log2 fold change estimates, p value and adjusted p value will all be set to NA.
  #If a row contains a sample with an extreme count outlier then the p value and adjusted p value will be set to NA. These outlier counts are detected by Cooks distance. Customization of this outlier filtering and description of functionality for replacement of outlier counts and refitting is described below
  #If a row is filtered by automatic independent filtering, for having a low mean normalized count, then only the adjusted p value will be set to NA. Description and customization of independent filtering is described below
  
  # re-create a new data frame
  NF1res$Gene_name = NF1res$symbol # design specific for DESeq for Peds Tissues
  NF1res <- data.frame(log2FoldChange = NF1res$log2FoldChange, Gene_name= NF1res$Gene_name, padj = NF1res$padj)
  
  # prepare color variable
  NF1res$color <- NF1res$padj<0.1
  
  # prepare labels to add, only have labels for those top genes
  add_labels <- rep("",nrow(NF1res))
  threshold <- max(head(sort(NF1res$padj),n )) # return the 50th genes
  index <- NF1res$padj<= threshold
  add_labels[index] <- as.character(NF1res$Gene_name[index])
  
  # fold those value in x (log2Fold Change) and y (Padj) 
  NF1res$log2FoldChange[NF1res$log2FoldChange>=xlim] = xlim
  NF1res$log2FoldChange[NF1res$log2FoldChange<=(-1*xlim)] = (-1* xlim)
  NF1res$padj[NF1res$padj<=1*10^(-1*ylim)] = 1*10^(-1*ylim)
  
  p1 <- ggplot(NF1res) +
    geom_point(aes(x=log2FoldChange, y=-log10(padj), colour=color)) +
    geom_text_repel(aes(x = log2FoldChange, y = -log10(padj), label = add_labels) ,max.overlaps = Inf) +
    ggtitle(paste(main)) +
    xlab("Log2 Fold Change") +
    ylab("-log10 Adjusted P-value") +
    #scale_y_continuous(limits = c(0,50)) +
    theme(legend.position = "none",
          plot.title = element_text(size = rel(1), hjust = 0.5),
          axis.title = element_text(size = rel(1)))
  
  return(p1)
}

## Converting each to dataframe and joining with annotation info

#create function to automate adding of annotation to each results file
annFun <- function(resultDE, annotation){
  x <- cbind.data.frame(ensemblvs=row.names(resultDE), resultDE)
  x <- join(annotation, x, by="ensemblvs", type="right")
  return(x)
}
# plot the heatmap for gsea results
heatmap_plot <- function(output, prefix, size = 14){
  p1 <- ggplot(output, aes(color=NES, y=reorder(pathway,pval), cex=size, x=padj)) +
    ylab("Pathways") +
    xlab("FDR") +
    labs(title= paste(prefix,"Pathways All")) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    theme(axis.text=element_text(size=size),axis.title=element_text(size=14,face="bold")) +
    #geom_segment(aes(x = 0.1, y = 25, xend = 0, yend = 25),
    #             arrow = arrow(), cex=0.8, color="darkgreen") +
    # annotate("text", x=0.18, y=25, label= "significant\n pathways", color="darkgreen") +
    # annotate("text", x=1, y=7, label= "down NF1", color="darkorange") +
    # annotate("text", x=1, y=13, label= "up NF1", color="blue") +
    coord_cartesian(clip="off")
  p1
}

## Generate ranked lists for each DEG list
## should se fold change or stat, do not use aboslute value

#Create function to order wald stat - smallest to largest - and then name with gene symbols
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

run_fgsea <- function(gsea,deseq,prefix, log2FC_threshold = 1.5, padj_threshold = 0.01){
  # Input: gsea, read by gseaPathways
  #        deseq: default deseq output, should have log2FoldChange, pval, padj, and stat
  #        prefix: prefix of this analysis
  #        log2FC_threshold: threshold used to filter data, on log2FC
  #        padj_threshold: threshold used to filter, on padj
  # Output: give the significant results only padj<=0.1, 
  #         given both up genes, down genes, and up/down genes results.
  #         label the category in groups columns, and the total number of used genes
  
  
  ### for test purpose
  #gsea <- geneSetCellType
  #deseq <- resN
  
  ## Check data matrix has na or not
  # sum(is.na(deseq$symbol))
  #[1] 0
  # sum(is.na(deseq$stat))
  #[1] 0
  # sum(is.na(deseq$padj))
  #[1] 3942
  # sum(is.na(deseq$log2FoldChange))
  #[1] 0
  
  ##1, remove NA, sort data, remove duplicatoin
  deseq <- deseq[ (!is.na(deseq$stat)) & 
                    (!is.na(deseq$padj))&
                    (!is.na(deseq$symbol)) &
                    (!is.na(deseq$log2FoldChange)), ]
  
  # sort the data frame first by symbol, then by reverse of baseMean (higher first)
  deseq_ordered <- deseq[ order(deseq$symbol, -(deseq$baseMean) ), ]
  
  # remove duplication
  deseq_ordered <- deseq_ordered[!duplicated(deseq_ordered$symbol),]
  
  ##2, Keep genes matching criteria
  
  # keep only certain genes with fold change and padj filter
  deseq_up_down <- deseq_ordered[abs(deseq_ordered$log2FoldChange)>=log2FC_threshold 
                                 & deseq_ordered$padj<= padj_threshold,]
  
  ##3,Prepare the rank for test from fold change
  
  # rank is a numeric vector with symbol as gene names
  rank_up_down <- as.numeric(deseq_up_down$stat[order(deseq_up_down$stat, decreasing = TRUE)])
  names(rank_up_down) <- deseq_up_down$symbol[order(deseq_up_down$stat, decreasing = TRUE)]
  
  rank_up <- rank_up_down[rank_up_down>0]
  rank_down <- rank_up_down[rank_up_down<0]
  
  ##4 Run GSEA on both up genes, down genes, and up/down genes
  output <- fgsea(pathways = gsea,
                  stats = rank_up_down,
                  minSize = 3,
                  nperm = 10000)
  output$category_gene_num= length(rank_up_down)
  output$category="Up_Down_Genes"
  output$bonferroni_p = p.adjust(output$pval,method ="b")

  up <- fgsea(pathways = gsea,
              stats = rank_up,
              minSize = 3,
              nperm = 10000)
  up$category_gene_num= length(rank_up)
  up$category="Up_Genes"
  up$bonferroni_p = p.adjust(up$pval,method ="b")
  
  
  down <- fgsea(pathways = gsea,
                stats = rank_down,
                minSize = 3,
                nperm = 10000)
  down$category_gene_num = length(rank_down)
  down$category="Down_Genes"
  down$bonferroni_p = p.adjust(down$pval,method ="b")
  
  ##5 Combine each result, and remove those are not significant
  output <- rbind(output, up, down)
  #output <- output[output$padj<0.1,]
  output <- output[order(output$bonferroni_p),]
  output$Analysis <- paste(prefix)
  #head(output)
  
  return(output)
}

run_DESEQ = function(data, formula, annotation, contrast){
  # this script is specifically design for PedsTissueRNASeq_DESeq_082020_Validated_byYW.R (dir:V3_AddGeneticInfo)
  # data: full data for DESeq, include group info and matrix for deseq
  # formula: formula used for DESeq
  # annotation: file used for gene name adding. 
  
  # for testing purpose
  #data <- ddsNoRep
  #formula = "~groupNF + lane + sex"
  
  design(data) <- formula(formula)
  data <- DESeq(data)
  
  output <- results(data, contrast = contrast)
  output <- annFun(output, annotation)
  output$foldchange <- 2^output$log2FoldChange
  output$bonferroni <- p.adjust(output$pvalue, method ="bonferroni")
  
  
  return(output)
  
  # potential output
  # summary(output)
  #Volcano_YW(output, main = "Output", 
  #           xlim = 10, ylim = 10, n = 30)
  

}

######################## MAPK pathways from curated pathways, GO #####

Plot_MAPK_GO <- function(input, prefix){
  #input <- NF1_GSEA_Renal
  #prefix <- "NF1_Renal"
  
  pathwaysMAPK <- input[grep("MAPK", input$pathway),]
  pathwaysMAPK <- pathwaysMAPK[grep("P38",pathwaysMAPK$pathway,invert = T),]
  pathwaysMAPK <- pathwaysMAPK[grep("BARR",pathwaysMAPK$pathway,invert = T),]
  pathwaysMAPK <- pathwaysMAPK[order(pathwaysMAPK$pval, decreasing=FALSE),] ##Order by pvalue
  pathwaysMAPK_All <- pathwaysMAPK[pathwaysMAPK$category=="Up_Down_Genes",]
  pathwaysMAPK_UP <- pathwaysMAPK[pathwaysMAPK$category=="Up_Genes",]
  pathwaysMAPK_DOWN <- pathwaysMAPK[pathwaysMAPK$category=="Down_Genes",]
  
  #colnames(pathwaysMAPK)
  #pathwaysMAPK$pathway
  # all genes
  p1 <- ggplot(pathwaysMAPK_All, aes(color=NES, y=reorder(pathway,desc(pval)), cex=size, x=padj)) + 
    ylab("MAPK-related Curated Pathways") +
    xlab("FDR") +
    labs(title = paste0("MAPK GO pathways : ",prefix, ", All Genes #: ", unique(pathwaysMAPK_All$category_gene_num)) ) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    geom_segment(aes(x = 0.1, y = nrow(pathwaysMAPK_All), xend = 0, yend = nrow(pathwaysMAPK_All)),
                 arrow = arrow(), cex=0, color="darkgreen") +
    #annotate("text", x=0.18, y=nrow(pathwaysMAPK), label= "significant\n pathways", color="darkgreen") +
    #annotate("text", x=1, y=5, label= "down NF1", color="darkorange") +
    #annotate("text", x=1, y=6, label= "up NF1", color="blue") +
    coord_cartesian(clip="off") +
    theme(axis.text=element_text(size=12))
  p1
  ggsave(paste0("GO_MAPK_AllGenes_",prefix,".png"), width = 11, height = 6.5)
  
  # only up genes
  p2 <- ggplot(pathwaysMAPK_UP, aes(color=NES, y=reorder(pathway,desc(pval)), cex=size, x=padj)) + 
    ylab("MAPK-related Curated Pathways") +
    xlab("FDR") +
    labs(title = paste0("MAPK GO pathways : ",prefix, ", Up regulated Genes #: ", unique(pathwaysMAPK_UP$category_gene_num)) ) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    geom_segment(aes(x = 0.1, y = nrow(pathwaysMAPK_UP), xend = 0, yend = nrow(pathwaysMAPK_UP)),
                 arrow = arrow(), cex=0, color="darkgreen") +
    #annotate("text", x=0.18, y=nrow(pathwaysMAPK), label= "significant\n pathways", color="darkgreen") +
    #annotate("text", x=1, y=5, label= "down NF1", color="darkorange") +
    #annotate("text", x=1, y=6, label= "up NF1", color="blue") +
    coord_cartesian(clip="off") +
    theme(axis.text=element_text(size=12))
  
  p2
  ggsave(paste0("GO_MAPK_UpGenes_",prefix,".png"), width = 11, height = 6.5)
  
  # only down genes
  p3 <- ggplot(pathwaysMAPK_DOWN, aes(color=NES, y=reorder(pathway,desc(pval)), cex=size, x=padj)) + 
    ylab("MAPK-related Curated Pathways") +
    xlab("FDR") +
    labs(title = paste0("MAPK GO pathways : ",prefix, ", Down regulated: Genes #: ", unique(pathwaysMAPK_DOWN$category_gene_num)) ) +
    geom_point() + geom_vline(xintercept=0.1) +
    scale_color_gradient(low="darkorange", high="blue") +
    geom_segment(aes(x = 0.1, y = nrow(pathwaysMAPK_DOWN), xend = 0, yend = nrow(pathwaysMAPK_DOWN)),
                 arrow = arrow(), cex=0, color="darkgreen") +
    #annotate("text", x=0.18, y=nrow(pathwaysMAPK), label= "significant\n pathways", color="darkgreen") +
    #annotate("text", x=1, y=5, label= "down NF1", color="darkorange") +
    #annotate("text", x=1, y=6, label= "up NF1", color="blue") +
    coord_cartesian(clip="off") +
    theme(axis.text=element_text(size=12))

  p3
  ggsave(paste0("GO_MAPK_DownGenes_",prefix,".png"), width = 11, height = 6.5)
}