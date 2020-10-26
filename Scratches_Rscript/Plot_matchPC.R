#### Rscript plot.R input prefix ratio
args <- commandArgs(trailingOnly = TRUE)
#args <- as.numeric(args)
#a <- read.table("ped_ctrl.afterQC.matchPC.list")
a <- args[1]
a <- read.table(args[1])
i = 1
xlim = range(c(a$V9,a$V5))
ylim = range(c(a$V10,a$V6))
pdf("MatchPC.pdf")
    #plot(a$V9,a$V10,pch = 16, col = "grey", cex = 0.5, xlim = c(-0.015, 0.04), ylim =c(-0.02,0.04), 
    plot(a$V9,a$V10,pch = 16, col = "grey", cex = 0.5, xlim = xlim, ylim = ylim, 
		        xlab = "PC1", ylab = "PC2", main = "All")
    legend("topright",col=c("red","grey"), legend = c("Case","Ctrl"), pch=16)
	points(a$V5,a$V6,col="red", pch = 16, cex = 0.5)
dev.off()

#for (i in 1:7){
#  range = (i*77-76):(i*77)
#  plot(a$V9[range],a$V10[range],pch = 16, col = "grey", cex = 0.5, xlim = c(-0.015, 0.04), ylim =c(-0.02,0.04), 
#       xlab = "PC1", ylab = "PC2", main = paste("Cycle:",i))
#  legend("topright",col=c("red","grey"), legend = c("Case","Ctrl"), pch=16)
#  points(a$V5[range],a$V6[range],col="red", pch = 16, cex = 0.5)
#  segments(a$V5[range],a$V6[range],a$V9[range],a$V10[range],lty = 3)
#}
