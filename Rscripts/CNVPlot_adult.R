# Detect change point 
#library(changepoint)
library(data.table)
library(pheatmap)

adult.list <- read.table("adult.list")
adult.list <- gsub("-",".", adult.list$V1)
data <- read.table("../Depth.normalized.100K", header = T)
chr_level <- unique(data$Group.1)
i = 1
# choose chromosome and samples
pdf("CNV_Heatmap.adult.pdf",width = 16, height = 9)
for(i in 1:length(chr_level)){
  chr = chr_level[i]
  sel <- data[data$Group.1==chr, colnames(data) %in% adult.list]
  chr.pos <- data$Group.2[data$Group.1==chr]
  depth <- sel[,3:ncol(sel)]
  row.names(depth) = chr.pos 
  #pheatmap(log2(depth+1), cluster_rows = F, cluster_cols = F)
  depth[depth>=1.5] = 1.5 # control the color degree
  depth[depth<=0.5] = 0.5 # control the color degree
  #pheatmap(log2(depth+1), cluster_rows = F, cluster_cols = F, main = paste("All Ped Samples: chr", chr,sep="") )
  pheatmap(depth, cluster_rows = F, cluster_cols = T, 
           main = paste("All Ped Samples: chr", chr,sep=""), show_rownames = F, show_colnames = T, fontsize_col = 5 )
}
# specifically for chr7, AD-0302, AD-0212
chr = 7 
sel <- data[data$Group.1==chr, colnames(data) %in% adult.list]
chr.pos <- data$Group.2[data$Group.1==chr]
depth <- sel[,3:ncol(sel)]
row.names(depth) = chr.pos 
depth[depth>=2] = 2 # control the color degree
depth[depth<=0] = 0 # control the color degree
pheatmap(depth[390:430,], cluster_rows = F, cluster_cols = T, 
         main = paste("All Ped Samples: chr7: 71.3-76.1M "), show_rownames = F, show_colnames = T, fontsize_col = 5 )

# for AD-0312

chr = 19
sel <- data[data$Group.1==chr, colnames(data) %in% adult.list]
chr.pos <- data$Group.2[data$Group.1==chr]
depth <- sel[,3:ncol(sel)]
row.names(depth) = chr.pos 
depth[depth>=2] = 2 # control the color degree
depth[depth<=0] = 0 # control the color degree
pheatmap(depth[50:80,], cluster_rows = F, cluster_cols = T, 
         main = paste("All Ped Samples: chr19: 5.2-8.4M"), show_rownames = F, show_colnames = T, fontsize_col = 5 )

dev.off()

