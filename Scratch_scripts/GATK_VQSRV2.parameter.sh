--resource hapmap,known=false,training=true,truth=true,prior=15.0:/home/yulywang/db/dbsnp/hapmap_3.3.hg19.sites.vcf.gz --resource omni,known=false,training=true,truth=true,prior=12.0:/home/yulywang/db/dbsnp/1000G_omni2.5.hg19.sites.vcf.gz --resource 1000G,known=false,training=true,truth=false,prior=10.0:/home/yulywang/db/dbsnp/1000G_phase1.snps.high_confidence.hg19.sites.vcf.gz --resource dbsnp,known=true,training=false,truth=false,prior=2.0:/home/yulywang/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an InbreedingCoeff --maximum-training-variants 100000000 -tranche 50 -tranche 60 -tranche 70 -tranche 80 -tranche 85 -tranche 90 -tranche 91 -tranche 92 -tranche 93 -tranche 94 -tranche 95 -tranche 96 -tranche 97 -tranche 98 -tranche 99 -tranche 99.5 -tranche 99.9 -tranche 100 
gatk4.0.5 VariantRecalibrator -R ~/db/human/hs37d5.fa -V /home/yulywang/FMD/SNVCalling/GenotypeGVCF/GATK.vcf.gz  --output  /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/snp.recal --tranches-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/snp.tranches  --resource hapmap,known=false,training=true,truth=true,prior=15.0:/home/yulywang/db/dbsnp/hapmap_3.3.hg19.sites.vcf.gz --resource omni,known=false,training=true,truth=true,prior=12.0:/home/yulywang/db/dbsnp/1000G_omni2.5.hg19.sites.vcf.gz --resource 1000G,known=false,training=true,truth=false,prior=10.0:/home/yulywang/db/dbsnp/1000G_phase1.snps.high_confidence.hg19.sites.vcf.gz --resource dbsnp,known=true,training=false,truth=false,prior=2.0:/home/yulywang/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode SNP --maximum-training-variants 100000000 --rscript-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/snp.R --max-gaussians 4; 
gatk4.0.5 VariantRecalibrator -R ~/db/human/hs37d5.fa -V /home/yulywang/FMD/SNVCalling/GenotypeGVCF/GATK.vcf.gz --output /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/indel.recal --tranches-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/indel.tranches --resource mills,known=false,training=true,truth=true,prior=12.0:/home/yulywang/db/dbsnp/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz --resource dbsnp,known=true,training=false,truth=false,prior=2.0:/home/yulywang/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz -an QD -an FS -an SOR -an ReadPosRankSum -an MQRankSum -mode INDEL --maximum-training-variants 10000000 --rscript-file indel.R --max-gaussians 4; gatk4.0.5 ApplyVQSR -R ~/db/human/hs37d5.fa --output /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/GATK.VQSR.indel.vcf --variant /home/yulywang/FMD/SNVCalling/GenotypeGVCF/GATK.vcf.gz --mode INDEL --recal-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/indel.recal --tranches-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/indel.tranches -ts-filter-level 99.0; gatk4.0.5 ApplyVQSR -R ~/db/human/hs37d5.fa --output /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/GATK.VQSR.snp.indel.vcf --variant /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/GATK.VQSR.indel.vcf --mode SNP --recal-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/snp.recal --tranches-file /home/yulywang/FMD/SNVCalling/GenotypeGVCF/tsV2_99/snp.tranches -ts-filter-level 99.0;