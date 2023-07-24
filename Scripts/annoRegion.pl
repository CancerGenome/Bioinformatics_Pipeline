#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./annoRegion.pl -c -b -e -g 
#                -c : chromosome field
#                -b : region start field
#                -e : region end field
#                -g : hg19 format
#
#  DESCRIPTION:  Given a region, annotation CDS info of this region,
#                Format: related_gene_in_this_region, region_size_for_each_gene
#                        TP53_173590_173595_5,another_gene 
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  05/10/2011 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;
our($opt_c,$opt_g,$opt_h,$opt_b,$opt_e);
getopts("c:b:e:gh");

$ARGV[0] || &usage();
&usage if ($opt_h);

$opt_c --;
$opt_b --;
$opt_e --;

while(<>) {
    chomp;
    print "$_\t";
    split;
    my $shell = "tabix /share/disk7-3/wuzhygroup/wangy/db/anno/hg18.pos2gene.gz $_[$opt_c]:$_[$opt_b]-$_[$opt_e]";
    if ($opt_g) {
        $shell =~ s/hg18/hg19/;
    }
    my @summary = `echo $shell |sh 2>/dev/null | cut -f1,5 | sort -k1,1 -k2n,2 | uniq `;
    chomp @summary;
    if (not defined $summary[0]) {
        print "\n";
        next;
    }
    my $last_gene = "" ;
    my $count = 0;
    my $last_pos = 0;
    for my $i (0..$#summary){

        my @split  = split/\s+/,$summary[$i];

        if($i == 0 ) {
            print "$split[0]_$split[1]_";
        }
        elsif($i == $#summary ) {
            print "$split[1]_$count,";
        }
        elsif($last_gene eq $split[0]) {
            $count ++;
        }
        elsif($last_gene ne $split[1]) {
           print "$last_pos\_$count,";
           print "$split[0]_$split[1]_";
           $count ++ ;
        }
        $last_gene = $split[0];
        $last_pos = $split[1];
    }
    print "\n";

}
