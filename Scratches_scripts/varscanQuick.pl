#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./varscanQuick.pl  -i <INPUT> -p [is bam] -g [is hg19]  -u [mouse]
#                -s [use your own text *.bam OR *.pileup,used with -p, comma separate]
#                -m -n : for mapping quality and base quality of solexa data
#                -q : do not qsub
#                -v : do snp calling
#
#  DESCRIPTION:  : quick qsub varscan screening
#       FORMAT:  : input should be table delimited and should be: normal file , tumor file, name
#                  if you own text, first command, second command, name
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/29/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

use Getopt::Std;
our ($opt_i,$opt_p,$opt_g,$opt_s,$opt_m,$opt_n,$opt_q,$opt_v,$opt_u);
getopts("i:pgsm:n:qvu");

open IN, "$opt_i";
while(<IN>) {
    chomp;
    next if $_ eq "";
    next if /#/;
    my @name;
    if ($opt_s) {
        @name = split/\,/,$_;
    }
    else {@name = split/\s+/,$_;}

    #---------------- Step one only for variation
if (defined $opt_v) {
    my $pileup = "samtools pileup -f \$reference $name[0]";
    if (defined $opt_m) {
        $pileup = "/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -Bq $opt_m -f ~/db/human/hs37d5.fa $name[0] ";
    }
    if (defined $opt_m && defined $opt_n) { 
        $pileup = "/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -Bq $opt_m -f ~/db/human/hs37d5.fa $name[0] | pileupTools -psf $opt_n -";
    }

open OUT,">$name[1].varscan.sh";
print OUT <<EOF;
    reference="~/db/human/hs37d5.fa"
    pileup="$pileup";
    bash -c "VarScan pileup2snp <(\$pileup) > $name[1].snp";
EOF

    if (defined $opt_g) {
        `sed -i 's/hg18\.fa/hg19\.fa/g' $name[1].varscan.sh `; 
        `sed -i 's/hg18\.map/hg19\.map/g' $name[1].varscan.sh `; 
    }
    if (defined $opt_u) {
        `sed -i 's/hg18\.fa/mm9\.fa/g' $name[1].varscan.sh `; 
        `sed -i 's/hg18\.map/mm9\.map/g' $name[1].varscan.sh `; 
    }
    `qsub.pl $name[1].varscan.sh` if (not defined $opt_q);
    close OUT;
    next; 
}

    #---------------- Step two, only for tumor variation
open OUT,">$name[2].varscan.sh";
if (defined $opt_p) {
    my $normal_pileup="samtools pileup -f \$reference $name[0]";
    my $tumor_pileup="samtools pileup -f \$reference $name[1]";

    if ($opt_s) {
        $normal_pileup = $name[0];
        $tumor_pileup = $name[1];
    }

    if ($opt_m ) {
        $normal_pileup = "/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -Bq $opt_m -f ~/db/human/hs37d5.fa $name[0] ";
        $tumor_pileup = "/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -Bq $opt_m -f ~/db/human/hs37d5.fa $name[1] ";
    }

    if ($opt_m && $opt_n) {
#        $normal_pileup = "samtools view $name[0] | awk '\\\$5>=$opt_m' | samtools pileup -Sf ~/db/human/hs37d5.fa - | pileupTools -psf $opt_n -";
#        $tumor_pileup = "samtools view $name[1] | awk '\\\$5>=$opt_m' | samtools pileup -Sf ~/db/human/hs37d5.fa - | pileupTools -psf $opt_n -";
        $normal_pileup = "/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -Bq $opt_m -f ~/db/human/hs37d5.fa $name[0] | pileupTools -psf $opt_n -";
        $tumor_pileup = "/share/disk7-3/wuzhygroup/wangy/bin/samtools mpileup -Bq $opt_m -f ~/db/human/hs37d5.fa $name[1] | pileupTools -psf $opt_n -";
    }

print OUT <<EOF;
    reference="~/db/human/hs37d5.fa"
    normal_pileup="$normal_pileup";
    tumor_pileup="$tumor_pileup";
    bash -c "VarScan somatic <(\$normal_pileup) <(\$tumor_pileup) $name[2]";
    VarScan somaticFilter $name[2].snp --min-coverage 6  --output-file $name[2].snp.filter ; mv $name[2].snp $name[2].snp.nofilter ; mv $name[2].snp.filter $name[2].snp;      
    grep -vE 'chrom|Germline' $name[2].snp | genoann -d ~/db/anno/hg18.map -m 4 - | tee $name[2].snp.anno.all | awk '\$8~/[ACGT]/' | grep -vE 'INTERGENIC|INTRON|=' | awk '\$6<=2 && \$10>=4' > $name[2].snp.anno
	sed '1d' $name.snp.anno.all  | awk 'BEGIN{OFS="\\t"}{\$2=\$2"\\t"\$2; print \$0}' > $name.annovar.input
	annovar --hgvs --outfile $name.snp.annovar $name.annovar.input
	perl -ane '{print join("\\t",\@F[2..\$\#F]),"\\t\$F[0]\\t\$F[1]\\n"}' $name.snp.annovar.variant_function > $name.snp.annovar.all
	sed 's/\ SNV/_SNV/g' $name.snp.annovar.exonic_variant_function | perl -ane '{print join("\\t",\@F[3..\$\#F]),"\\t\$F[1]\\t\$F[2]\\n"}' > $name.snp.annovar
	grep -Evw 'intronic|intergenic|ncRNA_intronic|exonic' $name.snp.annovar.all >> $name.snp.annovar
	msort -k b1,n2 $name.snp.annovar > cache; mv cache $name.snp.annovar
EOF

}
else {
print OUT <<EOF;
    VarScan somatic $name[0] $name[1] $name[2]
    VarScan somaticFilter $name[2].snp --min-coverage 6  --output-file $name[2].snp.filter ; mv $name[2].snp $name[2].snp.nofilter ; mv $name[2].snp.filter $name[2].snp
    grep -vE 'chrom|Germline' $name[2].snp | genoann -d ~/db/anno/hg18.map -m 4 - | tee $name[2].snp.anno.all | awk '\$8~/[ACGT]/' | grep -vE 'INTERGENIC|INTRON|=' | awk '\$6<=2 && \$10>=4' > $name[2].snp.anno
	sed '1d' $name.snp.anno.all  | awk 'BEGIN{OFS="\\t"}{\$2=\$2"\\t"\$2; print \$0}' > $name.annovar.input
	annovar --hgvs --outfile $name.snp.annovar $name.annovar.input
	perl -ane '{print join("\\t",\@F[2..\$\#F]),"\\t\$F[0]\\t\$F[1]\\n"}' $name.snp.annovar.variant_function > $name.snp.annovar.all
	sed 's/\ SNV/_SNV/g' $name.snp.annovar.exonic_variant_function | perl -ane '{print join("\\t",\@F[3..\$\#F]),"\\t\$F[1]\\t\$F[2]\\n"}' > $name.snp.annovar
	grep -Evw 'intronic|intergenic|ncRNA_intronic|exonic' $name.snp.annovar.all >> $name.snp.annovar
	msort -k b1,n2 $name.snp.annovar > cache; mv cache $name.snp.annovar
EOF
}

if (defined $opt_g) {
    `sed -i 's/hg18\.fa/hg19\.fa/g' $name[2].varscan.sh `; 
    `sed -i 's/hg18\.map/hg19\.map/g' $name[2].varscan.sh `; 
}
if (defined $opt_u) {
    `sed -i 's/hg18\.fa/mm9\.fa/g' $name[2].varscan.sh `; 
    `sed -i 's/hg18\.map/mm9\.map/g' $name[2].varscan.sh `; 
}
`qsub.pl $name[2].varscan.sh` if (not defined $opt_q);
}

__DATA__
    bash -c "VarScan somatic /share/disk7-3/wuzhygroup/wangy/hcc11/all/N0.pileup <(\$tumor_pileup) $name[2]"
    samtools view N0.bam | awk '\$5>=20' | samtools -Sf ~/db/human/hs37d5.fa - | pileupTools -psf 20 - 
