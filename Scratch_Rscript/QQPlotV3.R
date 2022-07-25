# QQPlotV3.R prefix 
# Design for traditionally burden test file
# Did not plot pathway here for V3, because pathway always have a lower p-value than single genes.
# Filter any pvalue higher than 0.95

# Read in Pvalue and Plot the figures
source("~/bin/QQplot_YW.R")

args <- commandArgs(trailingOnly = TRUE)
#args <- as.numeric(args)

input <- read.table(paste("../",args,".burden.allfisher.brown.method",sep=""), header = T)
#input <- input[input$Gene != "ARSD" &  input$Gene !="PTPRR" & input$Gene != "MATR3",]
input <- input[input$Chr !="multichrs",]

colname <- colnames(input)
sel <- c(5,6,8:11,13:16,18:21,23,24)
i = 0 

pdf("QQplot.pdf",width = 10 , height = 10)
par(mfrow=c(2,2))
for (i in 1:length(sel)){
	name = unlist(strsplit(colname[sel[i]],"\\.epacts"))
  #QQplot_YW(input[,sel[i]], input[,1], main = colname[sel[i]], top = 4, cex.main = 2, cex.lab = 1, cex = 0.5, cex.text = 1.2 )
  QQplot_YW(input[,sel[i]], input[,1], main = name[1], top = 4, cex.main = 1, cex.lab = 1, cex = 0.8, cex.text = 0.8, cex.axis = 1)
  #QQplot_YW(runif(1000), 1:1000)
}

par(mfrow=c(1,1))

QQplot_YW(input$LOF_0.01_brownP, input$Gene, top = 4, main = paste("LOF_0.01: QQ Plot for All genes")) 
QQplot_YW(input$LOF_0.05_brownP, input$Gene, top = 4, main = paste("LOF_0.05: QQ Plot for All genes")) 
QQplot_YW(input$LOF_Nonsyn_0.01_brownP, input$Gene, top = 4, main = paste("LOF_Nonsyn_0.01: QQ Plot All")) 
QQplot_YW(input$LOF_Nonsyn_0.05_brownP, input$Gene, top = 4, main = paste("LOF_Nonsyn_0.05: QQ Plot All")) 
QQplot_YW(runif(10000), 1:10000, main ="Uniform 10000 Test ")
dev.off()

system("pdftoppm -png -rx 300 -ry 300 QQplot.pdf plot")
#ped_2015 <- read.table(paste("../",args,".burden.forexcel",sep=""), header = T, skip = 1)
#ped_2015 <- ped_2015[ped_2015$Gene!="Syndromic_FMD_All_FBN1",]
#sel_2015 <- ped_2015[ped_2015$X2!=0,]
#QQplot_YW(sel_2015$brownP, sel_2015$Gene, top = 4, main = "QQ Plot for Ped Enriched")

