## Introdcution

Pipeline used for VarScan Somatic Variants detections

## Step 1: S1.bwa.sh

Mapped to genome with BWA

Assume you have downloaded the reference and created the index file. If not, use bwa index YOUR_REFERENCE_FASTA_FILE and find more details here: http://bio-bwa.sourceforge.net/bwa.shtml

- One Step to generate the BWA running shell.

> perl S1.bwa.pl BAM_LIST > S1.bwa.sh

> sh S1.bwa.sh 

Where BAM_LIST format is: FULL PATH BAM, one line each. 
Please replace /home/yulywang/db/human/hs37d5 and /home/yulywang/db/human/hs37d5.fai with your own reference index and index fai.

Breakdown for S1.bwa.sh steps:

- Assume the input file BAM file and name is TEST.bam, your should sort the id first for mapping purpose
> samtools sort -m 1600M --threads 4 -n -O BAM -o TEST.sortid.bam TEST.bam;

- Convert BAM to FASTQ, apply bwa with parameters below, you should replace with your own index file after -p
> samtools fastq TEST.sortid.bam | bwa7.17 mem -R "@RG\tID:AD-0057\tPL:Illumina\tLB:AD-0057\tDS:pe::0\tDT:2022-05-01\tSM:AD-0057\tCN:University_of_Michigan_Ganesh_Lab_YuWang" -t 4 -k 20 -w 105 -d 105 -r 1.3 -c 12000 -A 1 -B 4 -O 6 -E 1 -L 6 -U 18 -p /home/yulywang/db/human/hs37d5 - | gzip -3 > TEST.sam.gz;

- Convert SAM to BAM, replace your own index.fai file
> gzip -dc TEST.sam.gz | samtools view --threads 4 -b1ht /home/yulywang/db/human/hs37d5.fa.fai - > TEST.unsort.bam;

- Sort and index BAM files 
> samtools sort -m 1600M --threads 4 -O BAM -o TEST.sort.bam TEST.unsort.bam;samtools index TEST.sort.bam;

- Clean up everythings
> rm TEST.sortid.bam; rm TEST.sam.gz; rm TEST.unsort.bam; 

## Step 2: S2.Varscan.sh
- Call Somatic Variants with your processed Normal and Tumor BAM files;
> VarScan_Somatic_MIPS Normal.bam Tumor.bam Tumor.bam

Please change your reference files and bed file if analyzing your own data

## Step 3: S3.Filter.sh

- Concat all Varscan Output together
> head -n1 FASTQ/somatic/NTC.snp > Header2

> grep Somatic FASTQ/somatic/*snp | sort -k11g,11 | cat Header2 - | sed 's/\%//g' > Somatic.SNP

- Any variants with two occurence will be treated as Recurrent Variants
> less Somatic.SNP | quniq.pl -c2 -  | awk '$2>=2 ' > Somatic.SNP.recurrent

-  change to frequency 0.3
> fetch.pl -fq1 -d2 Somatic.SNP.recurrent Somatic.SNP  | awk '$11<=30 && $15<=0.05' | sort -k15g,15 | cat Header2 - > Somatic.SNP.p0.05.freq0.3.norecurrent
