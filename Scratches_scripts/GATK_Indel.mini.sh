--resource mills,known=false,training=true,truth=true,prior=12.0:/home/yulywang/db/dbsnp/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz --resource dbsnp,known=true,training=false,truth=false,prior=2.0:/home/yulywang/db/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf.gz -an QD -an FS -an SOR -an ReadPosRankSum -an MQRankSum  --maximum-training-variants 10000000  -tranche 50 -tranche 60 -tranche 70 -tranche 80 -tranche 85 -tranche 86 -tranche 87 -tranche 88 -tranche 89 -tranche 90 -tranche 91 -tranche 92 -tranche 93 -tranche 94 -tranche 95 -tranche 96 -tranche 97 -tranche 98 -tranche 99 -tranche 99.5 -tranche 99.9 -tranche 100 
