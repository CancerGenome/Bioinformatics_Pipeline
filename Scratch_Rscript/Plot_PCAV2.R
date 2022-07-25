##--- Declare function first
add_legend = function(){
  legend("topright", bty="n", cex=1, title="", c("African","East-Asian","Caucasian","FMD other","FMD ped","FMD Genetic Outlier"), fill=c("black","orange","royalblue","forestgreen","springgreen","red"))
  #legend("topright", bty="n", cex=1, title="", c("African","East-Asian","Caucasian","FMD","FMD Genetic Outlier"), fill=c("black","orange","royalblue","forestgreen","red"))
  #legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian"), fill=c("yellow","forestgreen","grey","royalblue","black"))
  #legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian"), fill=c("yellow","forestgreen","grey","royalblue","black"))
  #legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian","FMD"), fill=c("black","#E78AC3","orange","royalblue","forestgreen","red"))
}
add_points_PC12 = function(){
  points(a$PC1, a$PC2, col=col, pch=".", cex = 3)
  points(fmd_genetic_outlier$PC1, fmd_genetic_outlier$PC2, col = "red", pch =".",cex = 3)
  points(sel.ped$PC1, sel.ped$PC2, col = "springgreen", pch =".",cex = 3)
}

add_points_PC13 = function(){
  points(a$PC1, a$PC3, col=col, pch=".", cex = 3)
  points(fmd_genetic_outlier$PC1, fmd_genetic_outlier$PC3, col = "red", pch =".",cex = 3)
  points(sel.ped$PC1, sel.ped$PC3, col = "springgreen", pch =".",cex = 3)
}

draw_1000G <- function(){
  # draw all including 1000G and FMD
  points(a$PC1, a$PC2, col=col, pch=".", cex = 3) # all are grey, including FMD
}

draw_ctrl <- function(){
  # darw ctrl
  points(sel.ctrl$PC1, sel.ctrl$PC2, col = "royalblue", pch =".",cex = 3.5)
  points(ctrl.genetic.outlier$PC1, ctrl.genetic.outlier$PC2, col = "orange", pch =".",cex = 3.5)
}

draw_ped <- function(){
  # draw ped
  points(sel.ped$PC1, sel.ped$PC2, col = "springgreen", pch =".",cex = 3.5)
  points(ped.genetic.outlier$PC1, ped.genetic.outlier$PC2, col = "red", pch =".",cex = 3.5)
}

draw_legend_circle <- function(){
  # add legend
  legend("bottomright", bty="n", cex=1, title="", c("1000G","Pediatric","Removed Pediatric","Ctrl","Removed Ctrl"), fill=c("grey","springgreen","red","royalblue","orange"))
  draw.circle(m1,m2 ,radius =  c(scale_factor) * max(eur_dist), border = "grey")
}
draw_legend_circle_ped <- function(){
  # add legend
  legend("bottomright", bty="n", cex=1, title="", c("1000G","Pediatric","Removed Pediatric"), fill=c("grey","springgreen","red"))
  draw.circle(m1,m2 ,radius =  c(scale_factor) * max(eur_dist), border = "grey")
}
draw_legend_circle_ctrl <- function(){
  # add legend
  legend("bottomright", bty="n", cex=1, title="", c("1000G","Ctrl","Removed Ctrl"), fill=c("grey","royalblue","orange"))
  draw.circle(m1,m2 ,radius =  c(scale_factor) * max(eur_dist), border = "grey")
}


##---- Start 
#library("RColorBrewer")
library(plotrix)
a <- read.table("for_laser_plot.txt",header = T)
a$rank = nrow(a):1
a <- a[rank(a$rank),]
#relative <- read.table("../relative/")
#a <- a[!a$indivID %in% relative$V1,]
ped.list <- read.table("../ped.list")
sel.ped <- a[a$indivID %in% ped.list$V1,]
sel.noped <- a[!a$indivID %in% ped.list$V1,]
#col <- RColorBrewer::brewer.pal(6,"Set1")
#col <- RColorBrewer::brewer.pal(7,"Set2")

a$popID <- factor(a$popID, levels=c(
  "ACB","ASW","ESN","GWD","LWK","MSL","YRI",
  "CLM","MXL","PEL","PUR",
  "CDX","CHB","CHS","JPT","KHV",
  "CEU","FIN","GBR","IBS","TSI",
  "BEB","GIH","ITU","PJL","STU","FMD"))
col <- colorRampPalette(c(
  "black","black","black","black","black","black","black", # Africa
#"#E78AC3","#E78AC3","#E78AC3","#E78AC3", # Hispanic
"white","white","white","white", # Hispanic
  "orange","orange","orange","orange","orange", #  EAS
  "royalblue","royalblue","royalblue","royalblue","royalblue", # Caucasian
#  "forestgreen","forestgreen","forestgreen","forestgreen","forestgreen","red"))(length(unique(a$popID)))[factor(a$popID)] # South Asian
  "white","white","white","white","white","forestgreen"))(length(unique(a$popID)))[factor(a$popID)] # South Asian

# read those removed genetic outlier by FMD QC
#  list <- read.table("../remove_genetic_outlier/9.remove_genetic_outlier.list")
#  sel <- a[a$indivID %in% list$V1,]

eur <- a[a$popID=="CEU" | a$popID =="FIN" | a$popID=="GBR" | a$popID=="IBS" | a$popID=="TSI",]
m1 = mean(eur$PC1)
m2 = mean(eur$PC2)
m3 = mean(eur$PC3)
scale_factor = 1.5 # use this criteria to filter out: scale factor * max_eur_dist
#scale facotr from Rpackage plinkQC. https://cran.r-project.org/web/packages/plinkQC/plinkQC.pdf
eur_dist = sqrt((eur$PC1 -m1)^2 + (eur$PC2 -m2 )^2)
all_dist = sqrt((a$PC1 -m1)^2 + (a$PC2 -m2 )^2)
exclude_index = which(all_dist> scale_factor * max(eur_dist) )
all_genetic_outlier <- a[exclude_index,]
# genetic outliers of fmd samples;
fmd_genetic_outlier <- all_genetic_outlier[all_genetic_outlier$popID=="FMD",]
write.table(file = "Fail_Genetic_Outlier.rmped.list",fmd_genetic_outlier$indivID, sep ="\t", row.names = F, col.names = F, quote = F)
# genetic outliers of fmd, excluding pediatric samples
fmd_genetic_outlier <- fmd_genetic_outlier[!fmd_genetic_outlier$indivID %in% ped.list$V1,]
write.table(file = "Fail_Genetic_Outlier.list",fmd_genetic_outlier$indivID, sep ="\t", row.names = F, col.names = F, quote = F)

# code to draw the center and max-distance 
#max_index <- which.max(eur_dist)
#xx <- eur[max_index,]
#points(m1,m2,col="red", cex = 1)
#points(xx$PC1,xx$PC2,col="red", cex = 1)

pdf("PCA.pdf", height = 7, width = 14)

par(mar=c(5,5,5,5), cex = 1.5, cex.main= 2.5, cex.axis=1.5, cex.lab=1.5, mfrow=c(1,2))

### PC1 ~ PC2
plot(a$PC1, a$PC2, type="n", main="Population Structure of FMD", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp =1 )
add_points_PC12()
add_legend()
draw.circle(m1,m2 ,radius =  c(1,scale_factor) * max(eur_dist), border = "grey")

### PC1 ~ PC3
plot(a$PC1, a$PC3, type="n", main="PC1 PC3", adj=0.5, xlab="First component", ylab="Third component", font=1.5, font.lab= 1.5, asp = 1)
add_points_PC13()
add_legend()

### zoom in PC1 ~ PC2
ef = 0.01 # expanding factor for zoom in
plot(a$PC1, a$PC2, xlim = c(m1-ef, m1+ef),ylim =c(m2-ef, m2+ef),type="n", main="Population Structure of FMD", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp = 1 )
add_points_PC12()
add_legend()
draw.circle(m1,m2 ,radius =  c(1,scale_factor) * max(eur_dist), border = "grey")

### Zoom in PC1 ~ PC3
plot(a$PC1, a$PC3, xlim = c(m1-ef, m1+ef),ylim =c(m3-ef, m3+ef), type="n", main="PC1 PC3", adj=0.5, xlab="First component", ylab="Third component", font=1.5, font.lab= 1.5, asp = 1)
add_points_PC13()
add_legend()

#-------- Draw a figure suggested by Jun

col <- colorRampPalette(c(
  "grey","grey","grey","grey","grey","grey","grey", # Africa
  #"#E78AC3","#E78AC3","#E78AC3","#E78AC3", # Hispanic
  "white","white","white","white", # Hispanic
  "grey","grey","grey","grey","grey", #  EAS
  "grey","grey","grey","grey","grey", # Caucasian
  #  "forestgreen","forestgreen","forestgreen","forestgreen","forestgreen","red"))(length(unique(a$popID)))[factor(a$popID)] # South Asian
  "white","white","white","white","white","white"))(length(unique(a$popID)))[factor(a$popID)] # South Asian


sel.ped <- a[a$indivID %in% ped.list$V1,]
sel.ctrl <- a[grep("con", a$indivID),]
ped.genetic.outlier <- sel.ped[sel.ped$indivID %in% all_genetic_outlier$indivID,]
ctrl.genetic.outlier <- sel.ctrl[sel.ctrl$indivID %in% all_genetic_outlier$indivID,]

## Draw both ped and ctrl
plot(a$PC1, a$PC2, type="n", main="Population Structure of Ped/Ctrl", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp =1 )
draw_1000G();
draw_ctrl();
draw_ped();
draw_legend_circle();

## Zoom in with details
ef = 0.02 # expanding factor for zoom in
plot(a$PC1, a$PC2, xlim = c(m1-ef, m1+ef),ylim =c(m2-ef, m2+ef),type="n", main="Zoom In Version", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp = 1 )
draw_1000G();
draw_ctrl();
draw_ped();
draw_legend_circle();

## Draw both ped 
plot(a$PC1, a$PC2, type="n", main="Population Structure of Ped", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp =1 )
draw_1000G();
draw_ped();
draw_legend_circle_ped();

## Zoom in with details
ef = 0.02 # expanding factor for zoom in
plot(a$PC1, a$PC2, xlim = c(m1-ef, m1+ef),ylim =c(m2-ef, m2+ef),type="n", main="Zoom In Version", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp = 1 )
draw_1000G();
draw_ped();
draw_legend_circle_ped();

## Draw both ped and ctrl
plot(a$PC1, a$PC2, type="n", main="Population Structure of Ctrl", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp =1 )
draw_1000G();
draw_ctrl();
draw_legend_circle_ctrl();

## Zoom in with details
ef = 0.02 # expanding factor for zoom in
plot(a$PC1, a$PC2, xlim = c(m1-ef, m1+ef),ylim =c(m2-ef, m2+ef),type="n", main="Zoom In Version", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp = 1 )
draw_1000G();
draw_ctrl();
draw_legend_circle_ctrl();

dev.off()
