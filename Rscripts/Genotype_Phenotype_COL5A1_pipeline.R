# Design for calculate the association between gene and clinical phenotype
# Original resource: /home/yulywang/FMD/translate_arterial_bed/only264/StatisticsV2.R
# Follow up script: ~/bin/format_gene_clinical_output.pl
# Note 191219, fix a bug for number of test, 7 and 257 are fixed
# Note 191219, fix a bug for all samples are carrying this variant

calcfisher2 <- function(data){
  # input : four number used as fisher value
  # How to use this: fisher.pvalue <- apply(gatk[c("G.tref","G.tvar","G.nref","G.nvar")],1,calcfisher2)
  matrix <- matrix(as.numeric( data[c(1,2,3,4)] ) ,ncol = 2)
  if( sum(is.na(matrix)) >= 1 ){
    return(NA)
  }
  else{
    f1 <- fisher.test(as.table(matrix),alt="two.sided")
    return(f1$p.value)
  }
}

#data <- read.csv("MY_2019 V4 264 sample for COL5A1 - for R.csv")
# Update the new CSV, 191203 
data <- read.csv("~/bin/MY_2019 V4 264 sample for COL5A1 - for R_191203.csv")
#data <- read.csv("MY_2019 V4 264 sample for COL5A1 - for R_191203.csv.combined.phenotype")
data <- data[,2:ncol(data)]
data[data=="-"]  = 0
data$no.fmd.bin = ifelse(data$no.fmd>=1,1,0)
data$no.dissection.bin = ifelse(data$no.dissection>=1,1,0)
data$no.aneurysm.bin = ifelse(data$no.aneurysm>=1,1,0)
data$no.dissection.aneurysm.bin = ifelse(data$no.aneurysm + data$no.dissection>=1,1,0)

sample_gene <- read.table("sample.gene")
colnames(sample_gene) <- c("sample","gene")
sample_gene$gene <- as.character(sample_gene$gene)
unique_gene <- unique(sample_gene$gene)

m = 1 
type <- rep(c("fmd","aneurysm","dissection"), each = 12)
tissue <- rep(c("aorta","cerebral","cervical","ica","va","coronary","le","ue","visceral","mesenteric","renal","visceral.other"),  3)
list <- paste(type, tissue, sep =".")
group = c("no.fmd","no.aneurysm.bin","no.aneurysm","no.dissection.bin","no.dissection","no.dissection.aneurysm.bin")

output <- data.frame(matrix(ncol = 7, nrow = 0))

for (m in 1:length(unique_gene)){
  sel <- sample_gene[sample_gene$gene == unique_gene[m],]
  sel.data <- merge(sel, data, by.x = "sample", by.y ="AD.ID", all.y = T)
  sel.data <- sel.data[,2:ncol(sel.data)]
  sel.data$gene[is.na(sel.data$gene)]  = "ZZZZZZZ" # make sure always the last
  if(sum(sel.data$gene=="ZZZZZZZ") == 264) next; # all are NA
  if(sum(sel.data$gene== unique_gene[m]) == 264) next; # all are gene
  agg <- aggregate(. ~ gene, data = sel.data , function(x) sum(x,na.rm=T) ,na.action = na.pass)
  
  print(unique_gene[m])
  # process fisher exact pvalue
  input1 <- t(agg[list])
  
  input2 <- cbind(input1[,1], dim(sel)[1], input1[,2], 264 - dim(sel)[1])
  pvalue  <- apply(input2, 1, calcfisher2)
  c <- as.data.frame(cbind(unique_gene[m],input1[,1] + input1[,2], 
                           input1[,2], signif(input1[,2]/sum(sel.data$gene=="ZZZZZZZ"), digits = 3),
                           input1[,1], signif(input1[,1]/sum(sel.data$gene!="ZZZZZZZ"), digits = 3),
                           pvalue))
  output <- rbind(output,c)
  
  # processs t test for number separately
  sel7 <- sel.data[sel.data$gene==unique_gene[m],]
  sel257 <- sel.data[sel.data$gene!=unique_gene[m],]
  
  i = 1
  for(i in 1:length(group)){
    mean <- signif(mean( as.numeric(as.character( 
      unlist(sel.data[group[i]]) ))), digits = 2)
    sd <- signif(sd( as.numeric(as.character( 
      unlist(sel.data[group[i]]) ))), digits = 2)
    
    mean1 <- signif(mean( as.numeric(as.character( 
      unlist(sel7[group[i]]) ))), digits = 2)
    sd1 <- signif(sd( as.numeric(as.character( 
      unlist(sel7[group[i]]) ))), digits = 2)
    
    mean2 <- signif(mean( as.numeric(as.character( 
      unlist(sel257[group[i]]) ))), digits = 2)
    sd2 <- signif(sd( as.numeric(as.character( 
      unlist(sel257[group[i]]) ))), digits = 2)
    
    if(nrow(sel7) > 1 ){
      pvalue <- t.test(sel7[group[i]], sel257[group[i]], alternative = "greater")$p.value  
      
    }else{
      pvalue = NA
    }
    
    c1 <- c(unique_gene[m], 
            paste(mean,sd, sep ="+/-"), 
            paste(mean2,sd2, sep ="+/-"), "-", 
            paste(mean1,sd1, sep ="+/-"), "-",
            pvalue)
    c2 <- as.data.frame(t(c1))
    colnames(c2)[7]= "pvalue"
    rownames(c2) = group[i]
    output <- rbind(output, c2)
    #write.table( ,file = "Statistics.out",quote = F, sep ="\t", append = T)
  } # end t test
  
} # end gene

write.table(output, file = "Gene_Clinical.Ouput", quote = F ,sep ="\t")
