# Read in Pvalue and Plot the figures
QQplot_YW <- function(pval, gene, main = "Main", top = 3, cex = 0.5, cex.main = 2.5, cex.lab = 2, cex.axis = 2, offset = 0.5,cex.text = 1){
  # pval is the input of pvalue and should be a data frame or vector
  # gene is the gene list with same order of pval, typically from the same data frame
  # top means the top genes shown in the QQ plot
  # offset contrl the distance for text and its point
  
  #pval <- a$LOF_0.01_collapse.epacts
  #gene <- a$Gene
  index <- !is.na(pval)
  pval <- pval[index] # remove NA at this step
  gene <- gene[index]
  
  # Calculate lambda
  lambda <- median(qchisq(pval, df=1, lower.tail=FALSE),na.rm = T)/qchisq(0.5, 1)
  n <- length(pval)
  pval_exp <- seq(1/n, 1, length.out = n)
  pval_sort <- sort(pval)
  
  # Plot QQ between observed and expected
  x = -1*log10(pval_exp)
  y = -1*log10(pval_sort)
  plot(x,y , 
       xlab = "Exp(P)", ylab = "Obs(P)", main = paste(main), pch = 16, cex = 0.5,type = "p",
       cex.main = cex.main, cex.lab = cex.lab, cex.axis = cex.axis, xlim = c(0,round(max(x)+1) ), ylim =c(0,round(max(y)+1)),
       sub = paste("lambda:", signif(lambda, 3) ) )
  abline(a=0, b = 1, col = "red", lty = 2)
  
  # Add top gene names
  order <- order(pval) # first number is the index for the smallest number
  i = 0 
  for(i in 1:top){
    y = -1*log10(pval[order[i]]) # x -axis
    x = -1*log10(pval_exp[i])
    pos = (i+2)%%4
    if(pos ==0){pos = 4}
	gene_name = as.character(gene[order[i]])
	if(nchar(gene_name) >= 10){pos = 2}
	#if(nchar(gene_name) <= 4){pos = 4}
    text(gene[order[i]], x = x, y = y, col = "red", offset = offset, pos =  pos,cex = cex.text)  
    #text(gene[order[i]], x = x, y = y, col = "red", offset = offset, pos = 2 ,cex = cex.text)  
  }
}

input <- read.table("../ped.burden.allfisher.brown.method", header = T)
#input <- input[input$Gene != "ARSD" &  input$Gene !="PTPRR" & input$Gene != "MATR3",]
input <- input[input$Gene != "Syndromic_FMD_All_FBN1" ,]
colname <- colnames(input)
sel <- c(5,6,8,9)
i = 0 

pdf("QQplot.pdf")
par(mfrow=c(2,2))
for (i in 1:length(sel)){
	name = unlist(strsplit(colname[sel[i]],"_"))
  #QQplot_YW(input[,sel[i]], input[,1], main = colname[sel[i]], top = 4, cex.main = 1.5, cex.lab = 1.5, cex = 0.5, cex.text = 0.5)
  QQplot_YW(input[,sel[i]], input[,1], main = name[1], top = 4, cex.main = 1.5, cex.lab = 1.5, cex = 0.5, cex.text = 0.8)
}

par(mfrow=c(1,1))
ped_2015 <- read.table("../ped.burden.allfisher.forexcel", header = T, skip = 1)
ped_2015 <- ped_2015[ped_2015$Gene!="Syndromic_FMD_All_FBN1",]
sel_2015 <- ped_2015[ped_2015$X2!=0,]
QQplot_YW(ped_2015$brownP, ped_2015$Gene, top = 4, main = "QQ Plot for All genes (n = 9955)")
QQplot_YW(sel_2015$brownP, sel_2015$Gene, top = 4, main = "QQ Plot for Ped Enriched (n=2761)")

dev.off()
