# Given this script to the result from Run_BurdentestV16.sh
# will give QQ plot of deleterious analysis vs syn, traditional analysis vs syn
# as well as XY plot, and his plot
# also output significant genes which meet the genome wide significant and syn lowest pvalue
# Usage: Rscript Combine_Syn.R prefix
# Use this script to plot pvalue between deleterious variants and syn variants. 
# Version note, same category LoF_0.01 will have same genome wide significance

source("~/bin/QQplot_YW.R")
Plot_Burden_Syn_together <- function(burden, syn, prefix = "Deleterious"){
  # burden should be the burden test result, format, gene, follow by four test: collapse, madsen, vt, wcnt
  # syn should be the syn result, same format with burden
  # prefix: the analysis prefix, show in multiple figures
  
  ### For Test Purpose, will mask afterwise
  #burden <- Del[,c(1,9,10,12,13)]
  #syn <- Syn[,c(1,9,10,12,13)]
  #prefix="Deleterious"
  #burden <- Burden[,c(1,14,15,17,18)]
  #syn <- Syn[,c(1,24,25,27,28)]
  #prefix="LOF_0.05"
  
  Merge <- merge(burden, syn, by = "Gene")
  Merge[is.na(Merge)] <- 1 # set pvalue as 1 for NA
  #par(mfrow=c(2,2))
  test <- c("Collapse","Madsen","VT","WCNT")
  i = length(test)
  
  # define genome_wide_threshold
  length = 0 
  for(i in 1:length(test)){
	sel <- burden[paste(test[i])]
	sel <- sel[!is.na(sel)]
	sel <- sel[sel<= 0.98]
	length = max(length, length(sel))
  }
  genome_wide_threshold <- 0.05/length # enable same cateogry have same genome wide significant level

#### QQ plot with Exp Pvalue
    par(mfrow=c(2,4))
  for (i in 1:length(test)){
    ylim = max(-1*log10(min(burden[paste(test[i])], na.rm = T)), 
               -1*log10(min(syn[paste(test[i])], na.rm = T)), -1* log10(0.05/18000))
    ylim = floor(ylim) + 1
    xlim = floor(-1* log10(0.05/18000)) + 1
    #genome_wide_threshold <- QQplot_YW(burden[paste(test[i])], burden$Gene, xlim = xlim , ylim = ylim, main = paste(prefix,":", test[i]), top = 4,cex.text = 1.5, return_val = 1)
    QQplot_YW(burden[paste(test[i])], burden$Gene, xlim = xlim , ylim = ylim, main = paste(prefix,":", test[i]), top = 4,cex.text = 1.5, genome_wide_threshold = genome_wide_threshold)
    QQplot_YW(syn[paste(test[i])], syn$Gene, xlim = xlim , ylim = ylim, main = paste("Syn :", test[i]), top = 4,cex.text = 1.5, genome_wide_threshold = genome_wide_threshold)
    
    # print the gene names with genome significant and lower than syn.
    
    #genome_wide_threshold = 10^(-1*genome_wide_threshold)
    
    min_syn = min(syn[paste(test[i])], na.rm = T )
	min_syn = ifelse(min_syn>=0.01,0.01, min_syn)
    index1 <- burden[paste(test[i])] < genome_wide_threshold    # higher than genome wide
    index2 <- burden[paste(test[i])] < min_syn
    gene1 <- burden$Gene[index1]
    gene2 <- burden$Gene[index2]
    gene1 <- gene1[!is.na(gene1)]
    gene2 <- gene2[!is.na(gene2)]
    
    Significant_gene <- data.frame("SI" = "SI","Category" = prefix, "Test" = test[i], 
                                   "GT" = signif(genome_wide_threshold,digits=3), 
                                   "Genome_Wide" = paste(gene1, collapse =","),
                                   "ST" = signif(min_syn, digits=3),
                                   "Syn_Wide" = paste(gene2,collapse = ","),
                                   stringsAsFactors=FALSE)

    Significant_gene[Significant_gene==""] = "-"
	write.table(Significant_gene, file = "SignificantGene.Output", row.names = F ,quote =F, sep="\t", append = T)
#    print(Significant_gene, row.names = F)
#    print( paste(prefix, test[i], "Genome_Wide",paste(burden$Gene[index1], sep =","), "Syn_Wide" ,paste(burden$Gene[index2],collapse = ","), sep= " " )   )

}

#### X-Y plot for syn and nonsyn result of same gene
    par(mfrow=c(2,2))
  for (i in 1:length(test)){
    pval_a <- Merge[paste(test[i],"x",sep=".")] # this is original pvalue
    pval_b <- Merge[paste(test[i],"y",sep=".")]
    a = t(-log10(pval_a))
    b = t(-log10(pval_b))

	  xlim = round(max(b)) + 1
	  ylim = round(max(a)) + 1
    plot(b,a, ylab = "Obs(-logP)", xlab = "Syn(-logP)", 
         pch = 16, cex = 0.5,
         main = paste(prefix, "Vs Syn for test: ",test[i]) ,
         cex.lab = 1.5, cex.axis = 1.5, cex.main = 1.5,
		 xlim = c(-0.5,xlim),ylim =c(0,ylim))
    # show top genes
    top_n = 4 # number of gene to show
    Sel <- Merge[order(Merge[paste(test[i],"x",sep=".")])[1:top_n],]
    c <- -1*log10(Sel[paste(test[i],"x",sep=".")] )
    d <- -1*log10(Sel[paste(test[i],"y",sep=".")] )
    random = floor(runif(top_n , min = 1, max = 4))
    random[random==2] = 4 # 2 means left position
    random=c(3,1,3,1)
    text(t(d),t(c), labels = Sel$Gene, offset = 0.1, pos = random, cex = 1.2, col ="red" )
}
    
  #### X-Y plot for syn and nonsyn result of same gene, with lines
    par(mfrow=c(2,2))
    for (i in 1:length(test)){
      pval_a <- Merge[paste(test[i],"x",sep=".")] # this is original pvalue
      pval_b <- Merge[paste(test[i],"y",sep=".")]
      a = t(-log10(pval_a))
      b = t(-log10(pval_b))
      
      xlim = round(max(b)) + 1
      ylim = round(max(a)) + 1
      max_lim = max(xlim, ylim)
      plot(b,a, ylab = "Obs(-logP)", xlab = "Syn(-logP)", 
           pch = 16, cex = 0.5,
           main = paste(prefix, "Vs Syn for test: ",test[i]) ,
           cex.lab = 1.5, cex.axis = 1.5, cex.main = 1.5,
           xlim = c(-0.25,max_lim),ylim =c(0,max_lim))

      # show top genes
      #threshold = 1e-5
      #if(min(Merge[paste(test[i],"y",sep=".")], na.rm = T )<= threshold){
        threshold <- -log10(min(Merge[paste(test[i],"y",sep=".")]))
        threshold <- ceiling(threshold)
        threshold <- 10^(-1 * threshold)
      #}
      
      abline(v = -log10(threshold), lty = 2)
      abline(h = -log10(threshold), lty = 2)
      
      index <- (Merge[paste(test[i],"x",sep=".")] <= threshold | Merge[paste(test[i],"y",sep=".")] <= threshold)
      Sel <- Merge[index ,]
      c <- -1*log10(Sel[paste(test[i],"x",sep=".")] )
      d <- -1*log10(Sel[paste(test[i],"y",sep=".")] )
      random = floor(runif(top_n , min = 1, max = 4))
      random[random==2] = 4 # 2 means left position
      random=c(3,1,3,1)
      if(length(Sel$Gene)>0){
        text(t(d),t(c), labels = Sel$Gene, offset = 0.1, pos = random, cex = 1.2, col ="red" )  
      }
      
      # print the distribution for both syn and burden test
      table_x <- table( floor( -log10(Merge[paste(test[i],"x",sep=".")] )) )
      table_y <- table( floor( -log10(Merge[paste(test[i],"y",sep=".")] )) )
      table_x <- as.data.frame(table_x)
      table_y <- as.data.frame(table_y)
      table_merge <- merge(table_x, table_y, by= "Var1", all = T)
      table_merge[is.na(table_merge)] = 0
      colnames(table_merge) <- c("<1e-X","Obs","Syn")
      table_merge$Test = test[i]
      table_merge$Category = prefix
      table_merge$DI = "DI"
      #print(table_merge[c("DI","Category","Test","<1e-X","Obs","Syn")],row.names = F) #
      
    }

### QQ plot with corresponding syn variants
    par(mfrow=c(2,2))
  for (i in 1:length(test)){
    pval_a <- Merge[paste(test[i],"x",sep=".")] # this is original pvalue
    pval_b <- Merge[paste(test[i],"y",sep=".")]
    a = t(-log10(pval_a))
    b = t(-log10(pval_b))
	xlim = round(max(b)) + 1
	ylim = round(max(a)) + 1
    index <- (b >= -log10(0.98) & a>= -log10(0.98))
    lambda <- signif(
      median(qchisq(pval_a[index], df=1, lower.tail=FALSE),na.rm = T)/median(qchisq(pval_b[index], df=1, lower.tail=FALSE),na.rm = T), digits = 3)
    
    qqplot(b[index] , a[index], pch = 16, cex = 0.5,
           xlab = "Syn(-logP)", ylab = "Obs(-logP)", main = paste("QQPlot", prefix, "vs Syn", test[i], "N=", sum(index)),
           cex.lab = 1.5, cex.main = 1.5, sub = paste("lambda:",lambda),xlim =c(0,xlim), ylim =c(0,ylim) )
    abline(a=0,b=1, col ="red", lty = 2)
    # show top genes
    top_n = 4 # number of gene to show
    Sel <- Merge[index,]
    Sel <- Sel[order(Sel[paste(test[i],"x",sep=".")])[1:top_n],]
    
    c <- sort(a[index],decreasing = T)[1:top_n]
    d <- sort(b[index],decreasing = T)[1:top_n]
    #random = floor(runif(top_n , min = 1, max = 4))
    random=c(1,2,3,4)
    text(d,c, labels = Sel$Gene, pos = random, cex = 1.2, col ="red")
 }
    
 ### Dis of Obs and Syn pvalue distribution
    par(mfrow=c(2,4))
  for (i in 1:length(test)){
    pval_a <- Merge[paste(test[i],"x",sep=".")] # this is original pvalue
    pval_b <- Merge[paste(test[i],"y",sep=".")]
    a = t(-log10(pval_a))
    b = t(-log10(pval_b))
    index <- (b >= -log10(0.98) & a>= -log10(0.98))
    max <- ceiling(max(a,b))
    hist(a[index], br =100, xlim=c(0,max), main = paste(test[i],"Obs(-logP)"),xlab = "-logP")
    hist(b[index], br =100, xlim=c(0,max), main = paste(test[i],"Syn(-logP)"),xlab = "-logP" )
    #hist(a, br =100, xlim=c(0,max), main ="Obs(-logP)") # before remove low pvalue
    #hist(b, br =100, xlim=c(0,max), main = "Syn(-logP)")
}

}

###---- Read in dataset
args <- commandArgs(trailingOnly = TRUE)
Del <- read.table( paste("../Deleterious/",args,".burden.allfisher.forexcel",sep=""), header = T, stringsAsFactors = F, skip = 1)
Del <- Del[Del$Chr!="multichrs",]
Del <- Del[Del$Chr!="Y",]
Del <- Del[Del$Chr!="X",]

Header <- read.table( paste("../Syn/",args,".burden.forexcel",sep=""), header = F, nrows = 1, stringsAsFactors = F) # want to skip the second line
Syn <- read.table(paste("../Syn/",args,".burden.forexcel",sep="") , header = F, stringsAsFactors = F, skip = 2)
colnames(Syn) <- unlist(Header)
Syn <- Syn[Syn$Chr!="multichrs",]
Syn <- Syn[Syn$Chr!="X",]
Syn <- Syn[Syn$Chr!="Y",]
colnames(Syn)[32:35] = c("LOF_0.0001", "LOF_0.001","LOF_0.01","LOF_0.05")

####--- Predicted Deleterious vs synonymous ----
# For Predicted deleterious , using syn 0.0001 to match

pdf("Predict_Deleterious_Vs_Syn.pdf", width  = 12, height = 7)
Plot_Burden_Syn_together(Del[,c(1,9,10,12,13)], Syn[,c(1,9,10,12,13)])
par(mfrow=c(1,2))
QQplot_YW(Del$brownP, Del$Gene, top = 4, main = 'Deleterious BrownP', ylim = 10 )
QQplot_YW(Syn$LOF_0.0001, Syn$Gene, top = 4, main = 'Syn BrownP', ylim = 10)
dev.off()

####--- Traditionally Burden vs synonymous ----
# For LOF_0.01 and 0.05, using syn 0.01 and 0.05 to match, this is not perfer match
# For LOF_Nonsyn_0.01 and 0.05, using syn 0.01 and 0.05 to match,
# caution here, 
Header <- read.table( paste("../All/",args,".burden.forexcel",sep=""), header = F, nrows = 1, stringsAsFactors = F) # want to skip the second line
Burden <- read.table(paste("../All/",args,".burden.forexcel",sep=""), header = F, stringsAsFactors = F, skip = 2)
colnames(Burden) <- unlist(Header)
Burden <- Burden[Burden$Chr !="multichrs",]
Burden <- Burden[Burden$Chr !="X",]
Burden <- Burden[Burden$Chr !="Y",]
Burden <- Burden[Burden$Gene !="KMT2E",]
Burden <- Burden[Burden$Gene !="PPP6R2",]

pdf("Burden_Vs_Syn.pdf", width  = 12, height = 7)
Plot_Burden_Syn_together(Burden[,c(1,9,10,12,13)], Syn[,c(1,19,20,22,23)], prefix = "LOF_0.01")
Plot_Burden_Syn_together(Burden[,c(1,14,15,17,18)], Syn[,c(1,24,25,27,28)], prefix = "LOF_0.05")
Plot_Burden_Syn_together(Burden[,c(1,19,20,22,23)], Syn[,c(1,19,20,22,23)], prefix = "LOF_Nonsyn_0.01")
Plot_Burden_Syn_together(Burden[,c(1,24,25,27,28)], Syn[,c(1,24,25,27,28)], prefix = "LOF_Nonsyn_0.05")
par(mfrow=c(1,2))
QQplot_YW(Burden$LOF_0.01, Burden$Gene, top = 4, main = "LOF_0.01 BrownP", ylim = 10 )
QQplot_YW(Syn$LOF_0.01, Syn$Gene, top = 4, main = "Syn BrownP", ylim = 10 )
QQplot_YW(Burden$LOF_0.05, Burden$Gene, top = 4, main = "LOF_0.05 BrownP", ylim = 25 )
QQplot_YW(Syn$LOF_0.05, Syn$Gene, top = 4, main = "Syn BrownP", ylim = 25 )
QQplot_YW(Burden$LOF_Nonsyn_0.01, Burden$Gene, top = 4, main = "LOF_Nonsyn_0.01 BrownP", ylim = 10 )
QQplot_YW(Syn$LOF_0.01, Syn$Gene, top = 4, main = "Syn BrownP", ylim = 10 )
QQplot_YW(Burden$LOF_Nonsyn_0.05, Burden$Gene, top = 4, main = "LOF_Nonsyn_0.05 BrownP", ylim = 15 )
QQplot_YW(Syn$LOF_0.05, Syn$Gene, top = 4, main = "Syn BrownP", ylim = 15 )
dev.off()

system("head -n1 SignificantGene.Output > cache")
system("grep -v Category SignificantGene.Output >> cache")
system("mv cache SignificantGene.Output")
#system("pdftoppm -png -rx 300 -ry 300 Predict_Deleterious_Vs_Syn.pdf Predict_Deleterious_Vs_Syn")
#system("pdftoppm -png -rx 300 -ry 300 Burden_Vs_Syn.pdf Burden_Vs_Syn")
