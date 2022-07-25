# Combine enrichment scores using Fishers test with Brown's correction or IDR based approach
#library(idr)
## ----- Function and Declare ----
#https://docs.google.com/document/d/1LJDmUiFwQKhB1Pr9QzhUjoUkWDCC_ideU7U0uRhs4Ko/edit
library(plyr)
library("metap")
args <- commandArgs(trailingOnly = TRUE)

BROWN_FISHER_Method <- function(data){# convert list to numeric 
  b1=log(as.numeric(as.character(unlist(data[,1]))))
  b2=log(as.numeric(as.character(unlist(data[,2]))))
  b3=log(as.numeric(as.character(unlist(data[,3]))))
  b4=log(as.numeric(as.character(unlist(data[,4]))))
  b5=log(as.numeric(as.character(unlist(data[,5]))))
  c= cbind(b1,b2,b3,b4,b5)
  index <- rowSums(is.na(c))
  input = c[index == 0,]
  SCORES <- -2 * input
	N <- dim(SCORES)[2]
    #SCORES[apply(SCORES,2,is.infinite)] <- 1000  #Approximate all infinite scores to 1000 for calculation purpose
    
    correlation <- cor(SCORES);
    S <- 0
    for (i in 1:(N-1)){
      for (j in (i+1):N){
        S <- S + correlation[i,j]*(3.25+0.75*correlation[i,j])
      }
    }
    # E(x^2) = 2*N
    # sig(x^2) = 4*N + 2*S
    # freedom = 2 (E(x^2))^2 / sig(x^2) = 2*(2N)^2/(4N+2S) = 8N^2/(4N+2S) ~~ 2N if N is extreme large.
    # c = sig(X^2)/{2E(X^2)} = (4N+2S)/4N
    # FB.ChiSqure <- rowSums/c and get. 
    ChiSquare <- rowSums(SCORES)*(4*N)/(4*N+2*S)
    #FB.Pval <- sapply(FB.ChiSquare, function(x,N){pchisq(x, df = 2*N, lower.tail = FALSE)},N)
    #FB.Pval <- sapply(FB.ChiSquare, function(x,N){pchisq(x, df = (8*N*N/(4*N+2*S)), lower.tail = FALSE)},N)
    pval <- sapply(ChiSquare, function(x){pchisq(x, df = (8*N*N/(4*N+2*S)), lower.tail = FALSE)})
    #FB.Pval <- p.adjust(FB.Pval,'BH')

  # include NA if possible
  output <- rep(NA, dim(c)[1])
  output[index == 0] = pval
  return(signif(output,3))
}

FISHER_Method <- function(data1){
  data1 <- as.numeric(as.character(unlist(data1)))
  
  if(sum(!is.na(data1)) == 5){ # at least two non-na
    return(signif(sumlog(data1)$p,3 ) )
  }else{
    return(NA)
  }
}

newmin <- function(data1){
  return(min(data1, na.rm = T))
}

##---- Start Process ----

a <- read.table(args, header=T)
a[a=="-"] = NA
#nonskat <- grep("skat",colnames(a),invert = T)
#a <- a[,nonskat]

LOF_0.01_brownP <- BROWN_FISHER_Method(a[,5:9])
LOF_0.05_brownP <- BROWN_FISHER_Method(a[,10:14])
LOF_Nonsyn_0.01_brownP <- BROWN_FISHER_Method(a[,15:19])
LOF_Nonsyn_0.05_brownP <- BROWN_FISHER_Method(a[,20:24])

LOF_0.01_fisherP <- apply(a[,5:9],1,FISHER_Method)
LOF_0.05_fisherP <- apply(a[,10:14],1,FISHER_Method)
LOF_Nonsyn_0.01_fisherP <- apply(a[,15:19],1,FISHER_Method)
LOF_Nonsyn_0.05_fisherP <- apply(a[,20:24],1,FISHER_Method)

brownP_Min <- apply(cbind(LOF_0.01_brownP, LOF_0.05_brownP, LOF_Nonsyn_0.01_brownP, LOF_Nonsyn_0.05_brownP),1, function(x) return(min(x,na.rm=T)))
fisherP_Min <- apply(cbind(LOF_0.01_fisherP, LOF_0.05_fisherP, LOF_Nonsyn_0.01_fisherP, LOF_Nonsyn_0.05_fisherP),1, function(x) return(min(x,na.rm=T)))

LOF_0.01_brownP_BH <- p.adjust(LOF_0.01_brownP,'BH')
LOF_0.05_brownP_BH <- p.adjust(LOF_0.05_brownP,'BH')
LOF_Nonsyn_0.01_brownP_BH <- p.adjust(LOF_Nonsyn_0.01_brownP,'BH')
LOF_Nonsyn_0.05_brownP_BH <- p.adjust(LOF_Nonsyn_0.05_brownP,'BH')

LOF_0.01_fisherP_BH <- p.adjust(LOF_0.01_fisherP,'BH')
LOF_0.05_fisherP_BH <- p.adjust(LOF_0.05_fisherP,'BH')
LOF_Nonsyn_0.01_fisherP_BH <- p.adjust(LOF_Nonsyn_0.01_fisherP,'BH')
LOF_Nonsyn_0.05_fisherP_BH <- p.adjust(LOF_Nonsyn_0.05_fisherP,'BH')

brownP_BH_Min <- apply(cbind(LOF_0.01_brownP_BH, LOF_0.05_brownP_BH, LOF_Nonsyn_0.01_brownP_BH, LOF_Nonsyn_0.05_brownP_BH),1, function(x) return(min(x,na.rm=T)))
fisherP_BH_Min <- apply(cbind(LOF_0.01_fisherP_BH, LOF_0.05_fisherP_BH, LOF_Nonsyn_0.01_fisherP_BH, LOF_Nonsyn_0.05_fisherP_BH),1, function(x) return(min(x,na.rm=T)))


output <- cbind(a, signif( cbind(LOF_0.01_brownP, LOF_0.05_brownP, LOF_Nonsyn_0.01_brownP, LOF_Nonsyn_0.05_brownP, brownP_Min,
                LOF_0.01_brownP_BH, LOF_0.05_brownP_BH, LOF_Nonsyn_0.01_brownP_BH, LOF_Nonsyn_0.05_brownP_BH, brownP_BH_Min), 3) ) 

write.table( file = paste(args,"fisher.brown.method",sep =""),output, quote = F, sep="\t",row.names = F, col.names = T)

##---- Plot ----
# pdf("Brown_Fisher_Comparison.pdf", height = 9, width = 16)
# par(mfrow=c(2,2))
# qqplot(log10(LOF_0.01_brownP), log10(LOF_0.01_fisherP),main = "LOF_0.01",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# qqplot(log10(LOF_0.05_brownP), log10(LOF_0.05_fisherP),main = "LOF_0.05",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# qqplot(log10(LOF_Nonsyn_0.01_brownP), log10(LOF_Nonsyn_0.01_fisherP),main = "LOF_Nonsyn_0.01",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# qqplot(log10(LOF_Nonsyn_0.05_brownP), log10(LOF_Nonsyn_0.05_fisherP),main = "LOF_Nonsyn_0.05",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# 
# qqplot(log10(LOF_0.01_brownP_BH), log10(LOF_0.01_fisherP_BH),main = "LOF_0.01",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# qqplot(log10(LOF_0.05_brownP_BH), log10(LOF_0.05_fisherP_BH), main = "LOF_0.05",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# qqplot(log10(LOF_Nonsyn_0.01_brownP_BH), log10(LOF_Nonsyn_0.01_fisherP_BH), main = "LOF_Nonsyn_0.01",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# qqplot(log10(LOF_Nonsyn_0.05_brownP_BH), log10(LOF_Nonsyn_0.05_fisherP_BH), main = "LOF_Nonsyn_0.05",xlab="BrownP",ylab="FisherP")
# abline(a=0,b=1, col='black')
# dev.off()


#_---------- Sup

# b1=log(as.numeric(as.character(unlist(a[,17]))))
# b2=log(as.numeric(as.character(unlist(a[,18]))))
# b3=log(as.numeric(as.character(unlist(a[,19]))))
# b4=log(as.numeric(as.character(unlist(a[,20]))))
# c= cbind(b1,b2,b3,b4)
# index <- rowSums(is.na(c))
# c = c[index !=4, ]
# d= COMBINE_SCORES(-2*c)
# #table(d$FB.Pval)
# range(d$FB.Pval)
# 
# 
# 
# 
COMBINE_SCORES <- function(SCORES,SUB_METHOD = "FB" # options are FB or IDR
){
  # Calculate Fishers chi-square stat and p-value with Brown's correction
  # Score here should be -2logeP
  if (SUB_METHOD == 'FB'){
    N <- dim(SCORES)[2]
    SCORES[apply(SCORES,2,is.infinite)] <- 1000  #Approximate all infinite scores to 1000 for calculation purpose
    
    correlation <- cor(SCORES);
    S <- 0
    for (i in 1:(N-1)){
      for (j in (i+1):N){
        S <- S + correlation[i,j]*(3.25+0.75*correlation[i,j])
      }
    }
    # E(x^2) = 2*N
    # sig(x^2) = 4*N + 2*S
    # freedom = 2 (E(x^2))^2 / sig(x^2) = 2*(2N)^2/(4N+2S) = 8N^2/(4N+2S) ~~ 2N if N is extreme large.
    # c = sig(X^2)/{2E(X^2)} = (4N+2S)/4N
    # FB.ChiSqure <- rowSums/c and get. 
    FB.ChiSquare <- rowSums(SCORES)*(4*N)/(4*N+2*S)
    #FB.Pval <- sapply(FB.ChiSquare, function(x,N){pchisq(x, df = 2*N, lower.tail = FALSE)},N)
    #FB.Pval <- sapply(FB.ChiSquare, function(x,N){pchisq(x, df = (8*N*N/(4*N+2*S)), lower.tail = FALSE)},N)
    FB.Pval <- sapply(FB.ChiSquare, function(x){pchisq(x, df = (8*N*N/(4*N+2*S)), lower.tail = FALSE)})
    #FB.Pval <- p.adjust(FB.Pval,'BH')
    
    return(list(PVAL.CORRELATION = correlation, FB.Pval = FB.Pval))
    
  }else if (SUB_METHOD == 'IDR'){
    # Initial guess for theta
    N = dim(SCORES)[2]/2
    THRESHOLD <- median(as.matrix(SCORES))
    Mu <- median(apply(SCORES[rowSums(SCORES>=THRESHOLD)>=N,],1,mean))
    sigma <- median(apply(SCORES[rowSums(SCORES>=THRESHOLD)>=N,],1,sd))
    rho <- median(cor(t(SCORES[rowSums(SCORES>=THRESHOLD)>=N,])))
    p <- sum(rowSums(SCORES>=THRESHOLD)>=N)/dim(SCORES)[1]
    
    # Calculate IDR
    estIDR <- est.IDR(SCORES,Mu,sigma,rho,p,max.ite=100)
    
    # Combine results
    return(list(APVAL.CORRELTION = cor(SCORES), IDR = estIDR))
    
  } else{
    error('SUB_METHOD has to be FB or IDR')
  } 
}

