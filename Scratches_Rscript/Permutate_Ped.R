# Given a ped file, permutation the column of disease, keep all other sample
# Rscript Permutation_Ped.R INPUT
# output: permutation.ped
args <- commandArgs(trailingOnly = TRUE)
a <- read.table(args,comment.char ='^', header = T)
colnames(a)[1]= "#FID"
a$disease = a$disease[rank(runif(nrow(a))) ]
write.table(a, file="permutation.ped",row.names=F, col.names = T, quote = F, sep = "\t")
