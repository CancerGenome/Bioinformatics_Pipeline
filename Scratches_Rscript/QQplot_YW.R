
# Source Code for QQplot_YW
QQplot_YW <- function(pval, gene, main = "Main", top = 3, 
                      cex = 0.5, cex.main = 2, cex.lab = 2, cex.axis = 2, 
                      offset = 0.5, cex.text = 1, xlim = 0, ylim = 0, return_val = 0, genome_wide_threshold = 0  ){
  # pval is the input of pvalue and should be a data frame or vector
  # gene is the gene list with same order of pval, typically from the same data frame
  # top means the top genes shown in the QQ plot
  # offset contrl the distance for text and its point
  # return_val, whether return genome wide threshold, or not, default no
  #pval <- a$LOF_0.01_collapse.epacts
  #gene <- a$Gene
  index <- !is.na(pval)
  pval <- pval[index] # remove NA at this step
  gene <- gene[index]
  
  index2 <- (pval<=0.98)
  pval <- pval[index2] # wcnt and collapse are not sensitive to case:ctrl (3:0) and are generating a lot of close to 1 pvalue (one third or even more), therefore, remove them
  gene <- gene[index2]

  # Calculate lambda
  lambda <- median(qchisq(pval, df=1, lower.tail=FALSE),na.rm = T)/qchisq(0.5, 1)
  n <- length(pval)
  pval_exp <- seq(1/n, 0.98, length.out = n)
  pval_sort <- sort(pval)

  # Plot QQ between observed and expected
  x = -1*log10(pval_exp)
  y = -1*log10(pval_sort)
  threshold = signif(-1 * log10(0.05/length(gene)),digits=2) # genome wide thresholde

  if(genome_wide_threshold > 0 ){
	  threshold = signif( -1 * log10(genome_wide_threshold),digits=2) # genome wide thresholde
  }

  if(xlim == 0){
    xlim = round(max(x)+1)
  }
  if(ylim == 0){
    ylim = max(round(threshold+1), round(max(y)+2))
  }
  
  plot(x,y , 
       xlab = "Exp(-logP)", ylab = "Obs(-logP)", main = paste(main), pch = 16, cex = 0.5,
       cex.main = cex.main, cex.lab = cex.lab, cex.axis = cex.axis, xlim = c(0,xlim), ylim =c(0,ylim),
       sub = paste("lambda:", signif(lambda, 3) ) )
  abline(a=0, b = 1, col = "red", lty = 2)
  
  ## Add threshold
  abline(h = threshold, col ="grey")
  text(0.5, threshold, threshold)

  # Add top gene names
  order <- order(pval) # first number is the index for the smallest number
  i = 0 
  for(i in 1:top){
    y = -1*log10(pval[order[i]]) # x -axis
    x = -1*log10(pval_exp[i])
    pos = (i+2)%%4
    if(pos == 0){pos = 4}
	gene_name = as.character(gene[order[i]])
	#if(nchar(gene_name) >= 10){pos = 2}
	#if(nchar(gene_name) <= 4){pos = 4}
    text(gene[order[i]], x = x, y = y, col = "red", offset = offset, pos =  pos,cex = cex.text)  
    #text(gene[order[i]], x = x, y = y, col = "red", offset = offset, pos = 2 ,cex = cex.text)  
  }
  if(return_val == 1){
	  return(threshold)
  }
}
