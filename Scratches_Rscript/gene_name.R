args <- commandArgs(trailingOnly = TRUE)
gene_name <- read.table("~/db/gene_name",header=T)
omim <- read.table("~/db/omim/omim.gene.txt", header=T)
gene <- read.table(paste(args[1]) )
gene <- cbind(gene, data.frame(1:nrow(gene)))
colnames(gene) = c("V1","V2")
merge <- merge(gene_name, gene, by.x="Symbol",by.y="V1",all.x=F, all.y=T)
merge <- merge(omim,merge, by.x="Symbol",by.y="Symbol",all.x=F, all.y=T)
merge <- merge[order(merge$V2),]
merge$GeneCardLink = paste("https://www.genecards.org/cgi-bin/carddisp.pl?gene=",merge$Symbol,sep="")
merge$OMIMLink = ifelse(merge$OMIM=="NA","NA",paste("https://www.omim.org/entry/",merge$OMIM,"?highlight=",merge$Symbol,sep=""))
write.table(merge[,c(1,2,3,4,5,6,7,8,9)], file= paste(args[1],".gene.name",sep=""),quote=F, row.names=F, col.names=T,sep="\t")
print(paste(args[1],".gene.name",sep=""))

sel <- merge[,c("Symbol","OMIM","description","GeneCardLink","OMIMLink")]
write.table(sel, file= paste(args[1],".gene.name.lite",sep=""),quote=F, row.names=F, col.names=T,sep="\t")
print(paste(args[1],".gene.name.lite",sep=""))
