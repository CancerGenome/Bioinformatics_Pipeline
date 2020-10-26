# fast_annovar
I am writing my solution on fast Annovar annotation. You can choose to use this solution if:
1) You have so many samples in VCF file;
2) You spend a long time to wait Annovar result and hope to have a quicker solution here. 

Annovar is a very powerful tools for annotation, thanks for Dr. Kai Wang's contribution. When you run a super giant file, the majority of time you spend is on I/O. Therefore, avoiding input a multiple sample would save a lot of time. In this script, I kept only the first sample, and annovar it. Then paste all other sample information back. Done.  

# Requirement
1) You have run Annovar for at least one time, and know how it works;
2) Latest Annovar, bcftools, and bgzip;
3) Only VCF files are considered here; 
4) Run on Unix/Linux platform and batch are required. 

# Procedure
1) Download fast_annovar.sh in your local directory;
2) Use your editor to edit fast_annovar.sh -> line 24, replace your own ANNOVAR command line. There are four parts (see below strikethrough parts) you need to replace: your location of table_annovar.pl; your location of humandb; your annotation categories; and your annotation operation. 

  ~~\~/bin/tar/annovar/table_annovar.pl~~  $1 ~~\~/bin/tar/annovar/humandb/~~ -buildver hg19 -out $1 -remove -protocol ~~refGene~~ -operation ~~g~~ -nastring . -vcfinput

3) Run sh ./fast_annovar.sh INPUT.VCF.GZ
4) Check the file with a surfix of hg19_annovar.vcf.gz
