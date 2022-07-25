a <- read.table("FMD.missing_rate.0.98.imiss",header=T)
png("MissRate_Check.png",width = 720)
hist(1-a$F_MISS,br=100, main = "Call Rate Check", xlab = "Call Rate%",col="darkcyan")
dev.off()
