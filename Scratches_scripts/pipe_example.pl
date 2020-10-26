$reference="/share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa";
$normal_bam="HCC13-N0";
$tumor_bam="HCC13-T1";
$normal_pileup="samtools pileup -f $reference $normal_bam";
$tumor_pileup="samtools pileup -f $reference $tumor_bam";
#`head -10 <\($normal_pileup\)`;
`bash -c \"VarScan somatic <\($normal_pileup\) <\($tumor_pileup\) HCC13-T1.test\"`;
