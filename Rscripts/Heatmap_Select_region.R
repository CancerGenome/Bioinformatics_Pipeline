library(data.table)
library(pheatmap)

data <- fread("WES15_17.Target.CNVKit.Ratio.Merge.All.gz", data.table = F) # get a data frame
#rownames(data) <- data$Start
header <- read.table("header")
colnames(data) <- t(header)
chr_level <- unique(data$Chr)
i = 1
thr = 1 # threshold to fold log2


#-------- Selected Samples ---- 
adult.list <- read.table("Select.Adult.ctrl.list")
adult.list <- adult.list$V1[grep("UMAD|CCF",adult.list$V1)]

pdf("CNV_Heatmap.Selected.adult.pdf",width = 16, height = 9)
plot_region <- read.table("plot_region")
for(i in 1:length(plot_region$V1)){
  chr = plot_region$V1[i]
  pos1 = plot_region$V2[i] - (plot_region$V3[i]-plot_region$V2[i])
  pos2 = plot_region$V3[i] + (plot_region$V3[i]-plot_region$V2[i])
  sel <- data[data$Chr == chr & data$Start>= pos1 & data$End<= pos2, 
              as.character(adult.list)]
  depth <- sel
  rownames(depth) = data$Start[data$Chr == chr & data$Start>= pos1 & data$End<= pos2 ]
  depth[depth>=thr] = thr # control the color degree
  depth[depth<=-1*thr] = -1*thr # control the color degree
  label_row = round(as.numeric(rownames(depth))/1000000, digits=1)
  label_row2 = rep("",length(label_row))
  index = ((1:length(label_row)) %% 20 == 1)
  label_row2[index] = label_row[index]
  pheatmap(depth, cluster_rows = F, cluster_cols = T, 
           main = paste("Adult",chr,pos1,pos2), show_rownames = T, show_colnames = T, 
           fontsize_col = 20, labels_row = label_row2) # font size 
}
dev.off()

#-------------------- All Samples ----------------
#adult.list <- read.table("adult.ctrl.list")
adult.list <- read.table("adult.list")
adult.list <- adult.list$V1[grep("UMAD|CCF",adult.list$V1)]

pdf("CNV_Heatmap.adult.pdf",width = 16, height = 9)
plot_region <- read.table("plot_region")
for(i in 1:length(plot_region$V1)){
  chr = plot_region$V1[i]
  pos1 = plot_region$V2[i] - (plot_region$V3[i]-plot_region$V2[i])
  pos2 = plot_region$V3[i] + (plot_region$V3[i]-plot_region$V2[i])
  sel <- data[data$Chr == chr & data$Start>= pos1 & data$End<= pos2, 
              as.character(adult.list)]
  depth <- sel
  rownames(depth) = data$Start[data$Chr == chr & data$Start>= pos1 & data$End<= pos2 ]
  depth[depth>=thr] = thr # control the color degree
  depth[depth<=-1*thr] = -1*thr # control the color degree
  label_row = round(as.numeric(rownames(depth))/1000000, digits=1)
  label_row2 = rep("",length(label_row))
  index = ((1:length(label_row)) %% 20 == 1)
  label_row2[index] = label_row[index]
  
  pheatmap(depth, cluster_rows = F, cluster_cols = T, 
           main = paste("Adult",chr,pos1,pos2), show_rownames = T, show_colnames = T, 
           fontsize_col = 5, labels_row = label_row2)
}
dev.off()

#-------------------- All Samples + Control ----------------
adult.list <- read.table("adult.ctrl.list")
adult.list <- adult.list$V1[grep("UMAD|CCF",adult.list$V1)]

pdf("CNV_Heatmap.adult_ctrl.pdf",width = 16, height = 9)
plot_region <- read.table("plot_region")
for(i in 1:length(plot_region$V1)){
  chr = plot_region$V1[i]
  pos1 = plot_region$V2[i] - (plot_region$V3[i]-plot_region$V2[i])
  pos2 = plot_region$V3[i] + (plot_region$V3[i]-plot_region$V2[i])
  sel <- data[data$Chr == chr & data$Start>= pos1 & data$End<= pos2, 
              as.character(adult.list)]
  depth <- sel
  rownames(depth) = data$Start[data$Chr == chr & data$Start>= pos1 & data$End<= pos2 ]
  depth[depth>=thr] = thr # control the color degree
  depth[depth<=-1*thr] = -1*thr # control the color degree
  label_row = round(as.numeric(rownames(depth))/1000000, digits=1)
  label_row2 = rep("",length(label_row))
  index = ((1:length(label_row)) %% 20 == 1)
  label_row2[index] = label_row[index]
  
  pheatmap(depth, cluster_rows = F, cluster_cols = T, 
           main = paste("Adult",chr,pos1,pos2), show_rownames = T, show_colnames = T, 
           fontsize_col = 5, labels_row = label_row2)
}
dev.off()
