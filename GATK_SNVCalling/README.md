# Introduction
- All data were aligned to reference genome GRCh37 (hg19) with bwa 0.7.17 mem. <br>
- We followed the GATK (4.0.5.1) SNV calling best practices (https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-) and only two parameters were changed to accommodate computational resources (--max_records_in_ram and --max-reads-per-alignment-start). <br>
- The major procedures include 1) remove duplication with Picard, 2) Recalibrate Base Quality; 3) Combine all samples together and run HaplotypeCaller and generate GVCF; 4) Consolidate GVCF and Joint call all variants with CombineGVCF and GenotypeGVCF; <br>
- Finally, all high-quality variants were preserved if 1) the quality score is high (QD>=5,QUAL>=50, FS<=60, MQ>=40, MQRankSum>=-12.5, ReadPosRankSum=>-8, SOR<=3),  and 2) there are no SNV clusters within 10 bp (--cluster-size 3, --cluster-window-size 10). 

# Pipeline
### Layout of your folder:
Pipeline: for all your pipeline
FASTQ: for all you raw FASTQ files and all following BAM files;
CombineGVCF: temporay folder for 

### Prepare

Create new folder that are going to use. 

### Step 1, Mapping with BWA.
Assume you have downloaded the reference and created the index file. If not, use bwa index YOUR_REFERENCE_FASTA_FILE and find more details here: http://bio-bwa.sourceforge.net/bwa.shtml


### Step 2, Mark Duplicaton with Picard

### Step 3, Base Quality Recalibration and GVCF Infer

### Step 4 - 8 Combine GVCF, Merge Genotype, Hard Filtering and Annotation

### Step 9 Concat all together.
