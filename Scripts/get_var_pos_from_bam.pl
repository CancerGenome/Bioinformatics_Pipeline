#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./get_var_pos_from_bam.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  2011年03月08日 
#===============================================================================

use strict;
use warnings;

while(<>){
    chomp;
    split; # 
    next if ($_[5] ne "80M") ;
    my($id,$map_tag,$chr,$map_pos) = @_[0,1,2,3];
    my ($md,$pos,$tag) = qw{0 0 0};
    if(/MD:Z:(\S+)/) {
#       print $1,"\n";
        $md  = $1;
    }
    next if ($md eq 80);
#    print "$_\n";
#    $md ="75AT3G";
    my @md = split//,$md;
    my @var;

    #print "$md\n";
    for my $i(0..$#md){
        if ($tag ==1) {
            $tag = 0;
            next;
        }
#        print $i,"\n";
        if($md[$i] =~ /[ACGT]/){
            $pos ++;
            push (@var,$pos);
#            print "Push $pos\n";
        }
        if($md[$i] =~ /\d/){
           if (defined $md[$i+1] && $md[$i+1] =~ /\d/) {
            $pos += ($md[$i]*10 + $md[$i+1]);
            $tag = 1;
#            print "if $pos\n";
           }
           else {
            $pos += $md[$i];
#            print "else $pos\n";
           }

        }
    }
=head
    if  ($map_tag == 16) {
        foreach (@var) {
            $_ = 80 - $_ + 1;
        }
    }
=cut
#    print join("\t",@var),"\n";
    foreach (@var) {
        my $a = $map_pos -1 + $_;
        print "$a\t"; # print Pos information, MD has been covert to + strand
        if ($map_tag == 16) {
            $_ = 80 - $_ + 1;
        }
            print "$_\n";
    }
#    @var = @var+$map_pos;
#    print join("\t",@var),"\n";
    #print join("\t",(split/[ACGT]/,$md));

}
