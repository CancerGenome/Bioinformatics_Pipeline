# QQPlotV2.R prefix 
# Read in Pvalue and Plot the figures
# Filter any pvalue higher than 0.98
source("~/bin/QQPlot_YW.R")
args <- commandArgs(trailingOnly = TRUE)
#args <- as.numeric(args)

input <- read.table(paste("../",args,".burden.allfisher.brown.method",sep=""), header = T)
input <- input[input$Chr !="multichrs",]
colname <- colnames(input)
sel <- c(5,6,8,9)
i = 0 

pdf("QQplot.pdf")
par(mfrow=c(2,2))
for (i in 1:length(sel)){
	name = unlist(strsplit(colname[sel[i]],"_"))
  QQplot_YW(input[,sel[i]], input[,1], main = colname[sel[i]], top = 4, cex.main = 1.5, cex.lab = 1.5, cex = 0.5, cex.text = 0.9)
  #QQplot_YW(input[,sel[i]], input[,1], main = name[1], top = 4, cex.main = 1, cex.lab = 1, cex = 0.5, cex.text = 0.8) # smaller font
}

par(mfrow=c(1,1))
ped_2015 <- read.table(paste("../",args,".burden.allfisher.forexcel",sep=""), header = T, skip = 1)
ped_2015 <- ped_2015[ped_2015$Chr!="multichrs",]
sel_2015 <- ped_2015[ped_2015$X2!=0,]
QQplot_YW(ped_2015$brownP, ped_2015$Gene, top = 4, main = "QQ Plot for All genes")
QQplot_YW(sel_2015$brownP, sel_2015$Gene, top = 4, main = "QQ Plot for Ped Enriched")

dev.off()
system("pdftoppm -png -rx 300 -ry 300 QQplot.pdf plot")
