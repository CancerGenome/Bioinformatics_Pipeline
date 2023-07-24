a <- read.table("FMD.672.pass.0.98.sexcheck",header=T)
png("Gender_Check.png",width = 720)
hist(a$F, br=100, main ="Distribution of F for Gender Check", xlab = "F( X chromosome inbreeding coefficients from PLINK)", col="darkcyan")
dev.off()
