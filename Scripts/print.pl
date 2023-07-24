use warnings;
use strict;

my $root = "/share/disk3/solid/wangy";
my $cmap = "/share/disk3/solid/wangy/rice_validated.cmap";
my $ref = "/share/disk3/solid/wangy/chr1.ref";
my $gff = "/share/disk3/solid/wangy/chr1.gff.ano";
my $pile = "/share/disk3/solid/wangy/chr1.pileup";
my $qv = "/share/disk3/solid/wangy/chr1.qv";
my $snp_maq = "/share/disk3/solid/wangy/bin/snp_detect_maq.pl";
my $snp_cor = "/share/disk3/solid/wangy/bin/snp_detect_corona.pl";
my $cache = "/share/disk3/solid/wangy/cache/";

my $size = 1000000;
for my $i (31..40){
open OUT, ">$root/bin/$i.sh";
my $size1 = $size*$i;
my $size2 = $size1 - $size +1;
print OUT <<EOF
#------- do maq snp
sed -n '$size2,$size1\p' $pile > $i\_chr1.pileup
perl $snp_maq -ip $i\_chr1.pileup -c 1  -w 10 -n 1 -s -o maq.$i -sf 0 -sr 0
#------- do cor snp
awk '{if(\$4>$size2 && \$5< $size1) print }' $gff  > $i\.gff
perl $snp_cor -ref $ref -gff $i\.gff -cmap $cmap -out cor.$i -cov 1 -w 10 -spf 0 -spr 0
EOF

}
