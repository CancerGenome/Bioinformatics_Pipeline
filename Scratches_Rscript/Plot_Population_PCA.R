#library("RColorBrewer")
a <- read.table("for_laser_plot.txt",header = T)
a$rank = nrow(a):1
a <- a[rank(a$rank),]
#col <- RColorBrewer::brewer.pal(6,"Set1")
#col <- RColorBrewer::brewer.pal(7,"Set2")

a$popID <- factor(a$popID, levels=c(
  "ACB","ASW","ESN","GWD","LWK","MSL","YRI",
  "CLM","MXL","PEL","PUR",
  "CDX","CHB","CHS","JPT","KHV",
  "CEU","FIN","GBR","IBS","TSI",
  "BEB","GIH","ITU","PJL","STU","FMD"))
col <- colorRampPalette(c(
  "black","black","black","black","black","black","black", # Africa
  "#E78AC3","#E78AC3","#E78AC3","#E78AC3", # Hispanic
  "orange","orange","orange","orange","orange", #  EAS
  "royalblue","royalblue","royalblue","royalblue","royalblue", # Caucasian
  "forestgreen","forestgreen","forestgreen","forestgreen","forestgreen",adjustcolor("red",alpha.f  = 0.1)))(length(unique(a$popID)))[factor(a$popID)] # South Asian

pdf("PCA.pdf", height = 7, width = 7)

par(mar=c(5,5,5,5), cex = 1.5, cex.main=2.5, cex.axis=1.5, cex.lab=1.5, mfrow=c(1,1))

plot(a$PC1, a$PC2, type="n", main="Population struction of FMD and 1000 Genome samples", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5)
points(a$PC1, a$PC2, col=col, pch=".", cex=3)
#legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian"), fill=c("yellow","forestgreen","grey","royalblue","black"))
legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian","FMD"), fill=c("black","#E78AC3","orange","royalblue","forestgreen","red"))

plot(a$PC1, a$PC3, type="n", main="PC1 PC3", adj=0.5, xlab="First component", ylab="Third component", font=1.5, font.lab= 1.5)
points(a$PC1, a$PC3, col=col, pch=".", cex=3)
#legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian"), fill=c("yellow","forestgreen","grey","royalblue","black"))
legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian","FMD"), fill=c("black","#E78AC3","orange","royalblue","forestgreen","red"))

dev.off()

#  Old Script for COL5A1
# pdf("PCA.pdf")
# #col <- c("#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F","#E5C494")
# col <- c("red", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F","#E5C494")
# a$col = col[1]
# a$col[a$popID == "CEU"] = col[2]
# a$col[a$popID == "FIN"] = col[3]
# a$col[a$popID == "GBR"] = col[4]
# a$col[a$popID == "IBS"] = col[5]
# a$col[a$popID == "TSI"] = col[6]
# 
# plot(a$PC1,a$PC2, pch = 16, cex = 1, col = adjustcolor(a$col,alpha.f = 0.7),
#      xlab ="PC1", ylab="PC2", main ="Population structure for probands",
# 	 xlim = c(-0.15, 0.15), ylim = c(-0.15,0.15))
# sel <- a[1:4,]
# points(sel$PC1, sel$PC2, col = "red", cex = 1, pch = 8)
# legend("topright",pch = c(8,16,16,16,16,16), legend=c("Proband","CEU","FIN","GBR","IBS","TSI"), col = col)
# text(sel$PC1,sel$PC2, paste("Proband",1:4,sep=""))
# 
# dev.off()
