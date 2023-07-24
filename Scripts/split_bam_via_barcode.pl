#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  barcode_split.pl  -l [Barcode list] -f [Bam file and Barcode fastq]
#
#  DESCRIPTION:  Bam should be unsort, and bam file and barcode should be placed on after on ,each one a line;
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  01/24/2011 
#===============================================================================

)
}

#use strict;
use Getopt::Std;

# get option
our ($opt_l,$opt_h,$opt_f);
getopt("l:f:h");
&usage if ($opt_h);
&usage unless ($opt_l);

# open FileHandle
my @list = `less $opt_l`;
my %fh;

chomp @list;
push (@list,'else');
#print @list;

my ($bar_id,$bam_id,$barcode,$bam);
my @bam;

foreach my $i(0..$#list) {
#    my $fh = " |samtools view -bt ~/db/human/hg19.fa.fai -T ~/db/human/hg19.fa - > $list[$i].bam ";
#    my $cache = $list[$i];
#    $fh->$cache= FileHandle->new($fh);
    open ($fh{$list[$i]}," |samtools view -Sbt ~/db/human/hg19.fa.fai - > $list[$i].bam ") || die;
#    |samtools view -bt ~/db/human/hg19.fa.fai -T ~/db/human/hg19.fa - >$list[$i].bam ") || die;
#    open ($fh{$list[$i]},"|gzip > $list[$i].gz") || die;
    # || die ("** Failed to open $list[$i].bam");
}

open FILE,"$opt_f";
while(<FILE>) {
    chomp;
    split;
    open FQ, $_[0];

#    $_[1] = qw(cache.bam);
    system ("mkfifo a");
    system("samtools view $_[1] > a &");
    open BAM, "a";
#    print STDERR "1\n";
    &update_bar();
    &update_bam();

    while(1) {
#        print STDERR "1\n";
#        print STDERR $bar_id,"\t",$bam[0],"\n";
        if ($bar_id ne $bam[0]) {
            &update_bar();
        }
        else {
            if ($fh{$barcode}) {
                print {$fh{$barcode}} $bam,"\n" ;
            }
            else {
                print {$fh{"else"}} $bam,"\n";
            }
            &update_bar();
            &update_bam();
        }
    }

    system("rm a") ;

}

sub update_bar(){
        my $cache = <FQ>;
        chomp $cache;
        @_ = split/[\/@]/,$cache;
        $bar_id = $_[1];
#        print STDERR "$bar_id\n";
        last unless $bar_id;
        $barcode = <FQ>;
        chomp $barcode;
        <FQ>;
        <FQ>;
}

sub update_bam(){
        $bam = <BAM>;
        last unless $bam;
        @bam = split/\s+/,$bam;
#        $bam_id = (split/\#/,$bam[0])[0];
#        print STDERR $bam_id,"\n";
}

