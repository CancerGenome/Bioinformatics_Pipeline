ls ../FASTQ/*.rmdup.bam |xargs -i echo GATK_BQSR_GVCF.sh {} {}  | sed 's/.rmdup.bam$//' > S3.BQSR_GVCF.sh
/home/yulywang/bin/GATK_CombineGVCF_Merge_GenotypeGVCF_HardFilter_Annovar.pl -l GVCF.list > S5_8_CombineGVCF_Merge_GenotypeGVCF_HardFilter_Annovar.sh
bcftools query  -l ../GenotypeGVCF/MT_1_16569.HF_QD5_QUAL50.vcf.gz.hg19_annovar.vcf.gz| sed 's/_1\.fastq\.gz//' > reheader.sample.list
