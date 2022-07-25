#!/bin/bash
if [ $# -le 2 ] 
then echo "
#########################################################################
#      USAGE: ./QC_forBurdenTest.sh <Full Path PASS VCF file> <Sample List> <Ped List> 
#      Description:
#      Given a VCF file, perfom QC on samples ln sample list, PASS first
#      Output removed samples, removed list, and final VCF files with a QC prefix
#      Use ~ as separator for family and case Id, this will avoid split a_2 as family and case ID.
#                  
#      TODO: plink PCA only plot selected samples, do not need to plot all 1000G
#      FINISHED: variant shown as genetic outlier will be skipped in relative checking, and it will come back due to the draw backof scripts, for example 295 and 295_2 will be removed in PCA, but some of them are dup in the final results,should remove manually, due to two files of FMD samples
#      Author: Wang Yu #      Mail: yulywang@umich.edu
#      Created Time:  03/03/2020
#########################################################################
"
exit
fi

VCF=`readlink -f $1`;
SAMPLE=`readlink -f $2`;
PED=`readlink -f $3`;
#BED=$4; # do not use bed right now, place holder
DIR=`pwd`
cp $PED  $DIR/ped.list
export HOME='/home/yulywang'

shortID=${VCF%%.vcf.gz}
echo $shortID
MALEList='Male.list'
FEMALEList='Female.list'
FAILMISSINGRATE='Fail_MissRate.list'
FAILRELATIVELIST='Fail_Relative.list'
FAILRELATIVELIST_RMPED='Fail_Relative.rmped.list'

:<<'BLOCK'
BLOCK

## Prepare the data , change the ID
awk '{print $1"\t"$1}' $SAMPLE  > keep.sample.list
plink --vcf $VCF --make-bed --geno 0.02 --out FMD.672.pass.0.98 --id-delim '~' --double-id --keep keep.sample.list --threads 10  # caveat, the allele order here is changed by plink, not the right order of ref/non-ref. 

###### Processing Samples
##### Check Gender
mkdir $DIR/check_gender
cd $DIR/check_gender
plink -bfile ../FMD.672.pass.0.98 -check-sex -out FMD.672.pass.0.98 
awk '$NF>=0.35' FMD.672.pass.0.98.sexcheck  | sort -k6n,6 |awk '{print $1}' > MALEList
awk '$NF<0.35' FMD.672.pass.0.98.sexcheck  | sort -k6n,6 |awk '{print $1}' > FEMALEList
Rscript ~/bin/sexcheck.R

###### Sex Check R #############
# a <- read.table("FMD.672.pass.0.98.sexcheck",header=T)
# png("Gender_Check.png",width = 720)
# hist(a$F, br=100, main ="Distribution of F for Gender Check", xlab = "F( X chromosome inbreeding coefficients from PLINK)", col="darkcyan")
# dev.off()
################################

#### Check genetic outlier
mkdir $DIR/PCA
cd $DIR/PCA
fetch.pl -pq1,4 -d1,2 $DIR/FMD.672.pass.0.98.bim ~/FMD/COL5A1/1000Genome/CommonVariant_MAF0.1_ForPCA/1000G_Phase3_chr1_22_MAF0.1.pos | awk 'length($5) ==1 && length($6)==1' | cut -f1,4 > Overlap.pos
bcftools merge -R Overlap.pos $VCF ~/FMD/COL5A1/1000Genome/CommonVariant_MAF0.1_ForPCA/1000G_Phase3_chr1_22_MAF0.1.vcf.gz | bgzip --threads 10 > merge.vcf.gz
#bcftools merge -f PASS $VCF ~/FMD/COL5A1/1000Genome/CommonVariant_MAF0.1_ForPCA/1000G_Phase3_chr1_22_MAF0.1.vcf.gz | bcftools view -f PASS -c1 -i 'F_MISSING<=0.0000001' |  bgzip --threads 10 > merge.vcf.gz
plink --make-bed --vcf merge.vcf.gz --geno 0 --threads 10 --id-delim '~' --double-id 
plink --pca --exclude range ~/db/list/high_LD_region.bed --geno 0 -bfile plink 
combine.poupulation.pl plink.eigenvec | awk 'BEGIN{print "popID\tindivID\tPC1\tPC2\tPC3"}{print $1"\t"$2"\t"$3"\t"$4"\t"$5}' > for_laser_plot.txt

# this should be 3.5 or higher, PCAV2 will generate Genetic outlier.list
/sw/arcts/centos7/stacks/gcc/8.2.0/R/3.6.1/bin/Rscript ~/bin/Plot_PCAV2.R # PCA.pdf need to update the parameters for this step
# generate Fail_Genetic_Outlier.list

##### Check Missing Rate
mkdir $DIR/remove_relative
cd $DIR/remove_relative
plink -bfile ../FMD.672.pass.0.98 --missing -out FMD.missing_rate.0.98 
less FMD.missing_rate.0.98.imiss| awk '$6>=0.02'| awk '{print $1"\t"$1}' > $FAILMISSINGRATE
Rscript ~/bin/missrate.R
###### Miss Rate. R ############
# a <- read.table("FMD.missing_rate.0.98.imiss",header=T)
# png("MissRate_Check.png",width = 720)
# hist(1-a$F_MISS,br=100, main = "Call Rate Check", xlab = "Call Rate%",col="darkcyan")
# dev.off()
################################

##### Fork 1, remove ped samples as well
# Should first remove genetic outlier, otherwise same ancestry samples tend to have a higher PI_HAT
# https://groups.google.com/forum/#!topic/plink2-users/y8LWYyK8fgY
# stay in the same dir
awk '{print $1"\t"$1}' $FAILMISSINGRATE $DIR/PCA/Fail_Genetic_Outlier.rmped.list > Fail_MissingRate_Genetic_Outlier.list
plink -bfile ../FMD.672.pass.0.98 --geno 0  --out FMD.0.98 --genome --remove Fail_MissingRate_Genetic_Outlier.list --maf 0.1 --keep keep.sample.list
relatives_annotateV3.pl -g FMD.0.98.genome -m FMD.missing_rate.0.98.imiss  | sort -k6,6r > FMD.relatives
awk '$8>=0.35' FMD.relatives |cut -f1| sort | uniq | grep -v Delete | awk '{print $1"\t"$1}' > $FAILRELATIVELIST_RMPED # change for latest result
awk '$10>=0.2 || $10 =="PI_HAT"' FMD.0.98.genome > FMD.0.98.genome.0.2
Rscript ~/bin/relativecheck.R
Rscript ~/bin/relativecheck_All.R
mkdir relative_rmPed;
mv FMD.relatives Relative_Check.pdf Relative_Check_All.pdf FMD.0.98* Fail_MissingRate_Genetic_Outlier.list relative_rmPed

##### Fork 2, keep all ped samples
awk '{print $1"\t"$1}' $FAILMISSINGRATE $DIR/PCA/Fail_Genetic_Outlier.list > Fail_MissingRate_Genetic_Outlier.list
plink -bfile ../FMD.672.pass.0.98 --geno 0  --out FMD.0.98 --genome --remove Fail_MissingRate_Genetic_Outlier.list --maf 0.1
relatives_annotateV3.pl -g FMD.0.98.genome -m FMD.missing_rate.0.98.imiss  | sort -k6,6r > FMD.relatives
#less FMD.relatives |cut -f1| sort | uniq | grep -v Delete | awk '{print $1"\t"$1}' > $FAILRELATIVELIST
awk '$8>=0.35' FMD.relatives |cut -f1| sort | uniq | grep -v Delete | awk '{print $1"\t"$1}' > $FAILRELATIVELIST # change for latest result
awk '$10>=0.2 || $10 =="PI_HAT"' FMD.0.98.genome > FMD.0.98.genome.0.2
Rscript ~/bin/relativecheck.R
Rscript ~/bin/relativecheck_All.R
mkdir relative_Allped;
mv FMD.relatives Relative_Check.pdf Relative_Check_All.pdf FMD.0.98* Fail_MissingRate_Genetic_Outlier.list relative_Allped

########### Relative Check #############
# a <- read.table("FMD.0.98.genome.0.2",header=T)
# pdf("Relative_Check.pdf",width = 10)
# plot(jitter(a$Z2, amount = 0 )~ jitter(a$Z1,amount = 0 ), pch = 4, col = adjustcolor("red",alpha.f = 0.5), main = "Relative Check (PIHAT>=0.2)", xlab ="Z1, (IBD=1)% + random noise", ylab ="Z2, (IBD=2)% + random noise")
# dev.off()
########################################

###### Processing Variants
##### Fork One Remove PED
cd $DIR
cat remove_relative/$FAILMISSINGRATE remove_relative/$FAILRELATIVELIST_RMPED PCA/Fail_Genetic_Outlier.rmped.list  | awk 'BEGIN{print "CCF.con-0062\nCCF.con-0014"}{print $1}' |grep -vwf -  $SAMPLE > Sample.forVCF.rmped.list
bcftools view -S Sample.forVCF.rmped.list -f PASS -c1 -i 'F_MISSING<=0.02' $VCF | bcftools +fill-tags -- -t HWE | bcftools view -e 'HWE<1e-3' -Oz -o $shortID.removeFailSample.passHWE.rmped.vcf.gz --threads 10 
bcftools index -t $shortID.removeFailSample.passHWE.rmped.vcf.gz

####  Fork Two Keep all
cd $DIR
cat remove_relative/$FAILMISSINGRATE remove_relative/$FAILRELATIVELIST PCA/Fail_Genetic_Outlier.list  | awk 'BEGIN{print "CCF.con-0062\nCCF.con-0014"}{print $1}' |grep -vwf -  $SAMPLE > Sample.forVCF.list
bcftools view -S Sample.forVCF.list -f PASS -c1 -i 'F_MISSING<=0.02' $VCF | bcftools +fill-tags -- -t HWE | bcftools view -e 'HWE<1e-3' -Oz -o $shortID.removeFailSample.passHWE.vcf.gz --threads 10 
bcftools index -t $shortID.removeFailSample.passHWE.vcf.gz


#bcftools view -S $SAMPLE $VCF | bcftools view  -S ^FAIL.sample.rmped.list.forvcf --force-sample | bcftools view -f PASS -c1 -i 'F_MISSING<=0.02' -Oz -o $shortID.removeFailSample.rmped.vcf.gz --threads 10
#bcftools +fill-tags $shortID.removeFailSample.rmped.vcf.gz -- -t HWE | bcftools view -e 'HWE<1e-3' -Oz -o $shortID.removeFailSample.passHWE.rmped.vcf.gz --threads 10 
#bcftools index -t $shortID.removeFailSample.passHWE.rmped.vcf.gz
#bcftools view -S $SAMPLE $VCF | bcftools view  -S ^FAIL.sample.list.forvcf --force-sample | bcftools view -f PASS -c1 -i 'F_MISSING<=0.02' -Oz -o $shortID.removeFailSample.vcf.gz --threads 10
#bcftools +fill-tags $shortID.removeFailSample.vcf.gz -- -t HWE | bcftools view -e 'HWE<1e-3' -Oz -o $shortID.removeFailSample.passHWE.vcf.gz --threads 10 
# rm $shortID.removeFailSample.vcf.gz 

##################Plot PCA.R ############
# 
# ##--- Declare function first
# add_legend = function(){
#   legend("topright", bty="n", cex=1, title="", c("African","East-Asian","Caucasian","FMD other","FMD ped","FMD Genetic Outlier"), fill=c("black","orange","royalblue","forestgreen","springgreen","red"))
#   #legend("topright", bty="n", cex=1, title="", c("African","East-Asian","Caucasian","FMD","FMD Genetic Outlier"), fill=c("black","orange","royalblue","forestgreen","red"))
#   #legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian"), fill=c("yellow","forestgreen","grey","royalblue","black"))
#   #legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian"), fill=c("yellow","forestgreen","grey","royalblue","black"))
#   #legend("topright", bty="n", cex=1, title="", c("African","Hispanic","East-Asian","Caucasian","South Asian","FMD"), fill=c("black","#E78AC3","orange","royalblue","forestgreen","red"))
# }
# add_points_PC12 = function(){
#   points(a$PC1, a$PC2, col=col, pch=".", cex = 3)
#   points(fmd_genetic_outlier$PC1, fmd_genetic_outlier$PC2, col = "red", pch =".",cex = 3)
#   points(sel.ped$PC1, sel.ped$PC2, col = "springgreen", pch =".",cex = 3)
# }
# 
# add_points_PC13 = function(){
#   points(a$PC1, a$PC3, col=col, pch=".", cex = 3)
#   points(fmd_genetic_outlier$PC1, fmd_genetic_outlier$PC3, col = "red", pch =".",cex = 3)
#   points(sel.ped$PC1, sel.ped$PC3, col = "springgreen", pch =".",cex = 3)
# }
# 
# ##---- Start 
# #library("RColorBrewer")
# library(plotrix)
# a <- read.table("for_laser_plot.txt",header = T)
# a$rank = nrow(a):1
# a <- a[rank(a$rank),]
# relative <- read.table("../remove_relative/Fail_Relative.list")
# a <- a[!a$indivID %in% relative$V1,]
# ped.list <- read.table("../ped.list")
# sel.ped <- a[a$indivID %in% ped.list$V1,]
# #col <- RColorBrewer::brewer.pal(6,"Set1")
# #col <- RColorBrewer::brewer.pal(7,"Set2")
# 
# a$popID <- factor(a$popID, levels=c(
#   "ACB","ASW","ESN","GWD","LWK","MSL","YRI",
#   "CLM","MXL","PEL","PUR",
#   "CDX","CHB","CHS","JPT","KHV",
#   "CEU","FIN","GBR","IBS","TSI",
#   "BEB","GIH","ITU","PJL","STU","FMD"))
# col <- colorRampPalette(c(
#   "black","black","black","black","black","black","black", # Africa
# #"#E78AC3","#E78AC3","#E78AC3","#E78AC3", # Hispanic
# "white","white","white","white", # Hispanic
#   "orange","orange","orange","orange","orange", #  EAS
#   "royalblue","royalblue","royalblue","royalblue","royalblue", # Caucasian
# #  "forestgreen","forestgreen","forestgreen","forestgreen","forestgreen","red"))(length(unique(a$popID)))[factor(a$popID)] # South Asian
#   "white","white","white","white","white","forestgreen"))(length(unique(a$popID)))[factor(a$popID)] # South Asian
# 
# # read those removed genetic outlier by FMD QC
# #  list <- read.table("../remove_genetic_outlier/9.remove_genetic_outlier.list")
# #  sel <- a[a$indivID %in% list$V1,]
# 
# eur <- a[a$popID=="CEU" | a$popID =="FIN" | a$popID=="GBR" | a$popID=="IBS" | a$popID=="TSI",]
# m1 = mean(eur$PC1)
# m2 = mean(eur$PC2)
# m3 = mean(eur$PC3)
# scale_factor = 1.5 # use this criteria to filter out: scale factor * max_eur_dist
# #scale facotr from Rpackage plinkQC. https://cran.r-project.org/web/packages/plinkQC/plinkQC.pdf
# eur_dist = sqrt((eur$PC1 -m1)^2 + (eur$PC2 -m2 )^2)
# all_dist = sqrt((a$PC1 -m1)^2 + (a$PC2 -m2 )^2)
# exclude_index = which(all_dist> scale_factor * max(eur_dist) )
# all_genetic_outlier <- a[exclude_index,]
# # genetic outliers of fmd samples;
# fmd_genetic_outlier <- all_genetic_outlier[all_genetic_outlier$popID=="FMD",]
# # genetic outliers of fmd, excluding pediatric samples
# fmd_genetic_outlier <- fmd_genetic_outlier[!fmd_genetic_outlier$indivID %in% ped.list$V1,]
# write.table(file = "Fail_Genetic_Outlier.list",fmd_genetic_outlier$indivID, sep ="\t", row.names = F, col.names = F, quote = F)
# 
# # code to draw the center and max-distance 
# #max_index <- which.max(eur_dist)
# #xx <- eur[max_index,]
# #points(m1,m2,col="red", cex = 1)
# #points(xx$PC1,xx$PC2,col="red", cex = 1)
# 
# pdf("PCA.pdf", height = 7, width = 14)
# 
# par(mar=c(5,5,5,5), cex = 1.5, cex.main= 2.5, cex.axis=1.5, cex.lab=1.5, mfrow=c(1,2))
# 
# ### PC1 ~ PC2
# plot(a$PC1, a$PC2, type="n", main="Population Structure of FMD", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp =1 )
# add_points_PC12()
# add_legend()
# draw.circle(m1,m2 ,radius =  c(1,scale_factor) * max(eur_dist), border = "grey")
# 
# ### PC1 ~ PC3
# plot(a$PC1, a$PC3, type="n", main="PC1 PC3", adj=0.5, xlab="First component", ylab="Third component", font=1.5, font.lab= 1.5, asp = 1)
# add_points_PC13()
# add_legend()
# 
# ### zoom in PC1 ~ PC2
# ef = 0.01 # expanding factor for zoom in
# plot(a$PC1, a$PC2, xlim = c(m1-ef, m1+ef),ylim =c(m2-ef, m2+ef),type="n", main="Population Structure of FMD", adj=0.5, xlab="First component", ylab="Second component", font= 1.5, font.lab = 1.5, asp = 1 )
# add_points_PC12()
# add_legend()
# draw.circle(m1,m2 ,radius =  c(1,scale_factor) * max(eur_dist), border = "grey")
# 
# ### Zoom in PC1 ~ PC3
# plot(a$PC1, a$PC3, xlim = c(m1-ef, m1+ef),ylim =c(m3-ef, m3+ef), type="n", main="PC1 PC3", adj=0.5, xlab="First component", ylab="Third component", font=1.5, font.lab= 1.5, asp = 1)
# add_points_PC13()
# add_legend()
# 
# dev.off()
#########################
