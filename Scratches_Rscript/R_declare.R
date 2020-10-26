calcfisher2 <- function(data){
  # input : four number used as fisher value 
  # How to use this: fisher.pvalue <- apply(gatk[c("G.tref","G.tvar","G.nref","G.nvar")],1,calcfisher2)
  matrix <- matrix(as.numeric( data[c(1,2,3,4)] ) ,ncol = 2)
  if( sum(is.na(matrix)) >= 1 ){
	return(NA)
  }
  else{
	f1 <- fisher.test(as.table(matrix),alt="two.sided")
	#f1 <- fisher.test(as.table(matrix),alt="less")
	  return(f1$p.value)
  }
}

plot_each_software=function(data,list,main,opt = 1){ 
  # Design for Six methods and GATK results plotting
  # Will plot overall results with different color, 
  # format of data: c("chr","pos","tref","tvar","nref","nvar","M.status","S.status","V.status","MR.status","SR.status","VR.status","fisher.pvalue")
  # list, the list of sample name, opt: 1: read depth as point size(cex); 2:pvalue as point size(cex)
  #par(mfrow=c(2,3))
  # Example of function: plot_each_software(data,c("M.status","S.status","V.status","MR.status","SR.status","VR.status"),"Six Methods, before any filter")
  
  plot(data$nfreq, data$tfreq, cex = 0.8, pch="", col=rgb(0,0,0,alpha = 0.5), xlim=c(0,1),ylim=c(0,1),xlab="Normal Freq",ylab="Tumor Freq",main=main)
  color = c("#FF0000","navy","olivedrab","tomato","#008080","#8BA48B")
  #color <- c("#7C0607","#A45657","#D0A8A8","#1F28A2","#6567AA","#AEAFCF")
  color.adjust <- adjustcolor(color, alpha=0.4 ) 
  for(i in 1:length(list)){
    data[,list[i]] <- addNA(data[,list[i]])
    sel <- data[data[,list[i]]=="PASS" | data[,list[i]]=="Somatic" | data[,list[i]]=="LOH" | data[,list[i]]=="Unknown",]
    # define point size
    if(opt == 1){
      sel$cex <- log10(sel$tref+sel$tvar)/3  #define cex with log10 read depth
    }
    if(opt == 2){
      sel$cex <- log2(-1*log10(sel$fisher.pvalue))/3  #define cex with log10 read depth
    }
    par(new = T)
    plot(sel$nfreq, sel$tfreq ,cex = sel$cex , pch = 16, xlim=c(0,1),ylim=c(0,1),axes=F,xlab="",ylab="",main="",col=color.adjust[i] )
  }
  legend("topright",col=color, legend = list,pch=16)
  if(opt == 1){
    legend("bottomright",col= "red" , legend = c("TDepth","10","50","100","500","1000"), pt.cex = log10(c(1,10,50,100,500,1000))/3 , pch=16 )#legend with log10 read depth
  }
  if(opt == 2){
    legend("bottomright", col= "red" , legend = c("-log10p","2","5","10","20","50","100"), pt.cex = log2(c(1,2,5,10,20,50,100))/3, pch=16 )#legend with log10 read depth
  }
  
  # plot separate
  #list <- c("M.status","S.status","V.status","MR.status","SR.status","VR.status")
  par(mfrow=c(2,3))
  for(i in 1:length(list)){
    data[,list[i]] <- addNA(data[,list[i]])
    sel <- data[data[,list[i]]=="PASS" | data[,list[i]]=="Somatic" | data[,list[i]]=="LOH" | data[,list[i]]=="Unknown",]
    # plot different category for varscan
    if(list[i] !="V.status" & list[i] != "VR.status"){
      plot(sel$nfreq, sel$tfreq ,cex = 0.5, pch = 16, xlim=c(0,1),ylim=c(0,1),xlab="Normal Freq",ylab="Tumor Freq",main=paste(list[i]),col=color[i] )
    }
    else{
      sel$col <- ifelse(sel[,list[i]] == "Somatic", "orange","white" )
      sel$col <- ifelse(sel[,list[i]] == "LOH", "navy", sel$col )
      sel$col <- ifelse(sel[,list[i]] == "Unknown", "olivedrab", sel$col )
      plot(sel$nfreq, sel$tfreq ,cex = 0.5, pch = 16, xlim=c(0,1),ylim=c(0,1),xlab="Normal Freq",ylab="Tumor Freq",main=paste(list[i]),col = sel$col )
      legend("topright",col=c("orange","navy","olivedrab"), legend = c("Somatic","LOH","Unknown"),pch=16)
    }
    #legend("topright",col=color, legend = list,pch=16)
  }
  par(mfrow=c(1,1))
}
redblue100 <- rgb(read.table("~/bin/redblue100.txt",sep="\t", row.names = 1, header=T))
rotate <- function(x) t(apply(x, 2, rev)) # t flip along the diagonal, and rotate 90 degree rotation of R matrix
