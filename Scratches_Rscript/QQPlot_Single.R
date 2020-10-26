source("~/bin/QQplot_YW.R")
args <- commandArgs(trailingOnly = TRUE)
#args <- "ped_matchPC.single.combine.forexcel"
system(paste("cut -f1-21", args ," > cache"))
data <- read.table("cache", stringsAsFactors = F, header = T)

# pdf("Single_Variant.Test.pdf", width = 12, height = 7)
# QQplot_YW(as.numeric(data$score), data$Gene.refGene, top = 4, main = "QQ Plot for Score Test ")
# QQplot_YW(as.numeric(data$wald), data$Gene.refGene, top = 4, main = "QQ Plot for Wald Test ")
# dev.off()
png("Single_Variant.png",width = 1200, height = 700)
par(mfrow=c(1,2))
QQplot_YW(as.numeric(data$score), data$Gene.refGene, top = 4, main = "QQ Plot for Score Test ", cex.text = 1.2)
QQplot_YW(as.numeric(data$wald), data$Gene.refGene, top = 4, main = "QQ Plot for Wald Test ", cex.text = 1.2)
dev.off()

system("rm cache")
