## Concat all Varscan Output together
head -n1 FASTQ/somatic/NTC.snp > Header2
grep Somatic FASTQ/somatic/*snp | sort -k11g,11 | cat Header2 - | sed 's/\%//g' > Somatic.SNP

## Any variants with two occurence will be treated as Recurrent Variants
less Somatic.SNP | quniq.pl -c2 -  | awk '$2>=2 ' > Somatic.SNP.recurrent

##  change to frequency 0.3
fetch.pl -fq1 -d2 Somatic.SNP.recurrent Somatic.SNP  | awk '$11<=30 && $15<=0.05' | sort -k15g,15 | cat Header2 - > Somatic.SNP.p0.05.freq0.3.norecurrent

