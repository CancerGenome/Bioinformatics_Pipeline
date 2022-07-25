#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./processHcc11Combine.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  06/01/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

my (@Hq_ref,@ref,@Hq_mut,@mut,@Hcc_ref,@Hcc_mut);
my ($Hq_ref_sum,$ref_sum,$Hq_mut_sum,$mut_sum,$Hcc_ref_sum,$Hcc_mut_sum);
my ($Hq_ref_max,$ref_max,$Hq_mut_max,$mut_max,$Hcc_ref_max,$Hcc_mut_max);
my ($chr,$pos);
while(<>){
    chomp;
    my @array = split;
    ($chr,$pos)= @array[0,1];
    #----- Get Array for each component
    my ($a,$b) =  &number_series(0,1,13,2);
    my @a = @{$a}; my @b = @{$b};
    #print "B\t",join(" ",@b),"\n";
    @Hq_ref = @array[@a];
    @Hq_mut = @array[@b];
    ($a,$b)=  &number_series(28,1,13,2);
    @a = @{$a}; @b = @{$b};
    @ref = @array[@a];
    @mut = @array[@b];
    ($a,$b) =  &number_series(58,1,6,2);
    @a = @{$a}; @b = @{$b};
    @Hcc_ref = @array[@a];
    @Hcc_mut = @array[@b];

    #----- Get numbers of each component;
    ($Hq_ref_sum,$Hq_ref_max) = &sum_max(@Hq_ref);
    ($Hq_mut_sum,$Hq_mut_max) = &sum_max(@Hq_mut);
    ($ref_sum,$ref_max) = &sum_max(@ref);
    ($mut_sum,$mut_max) = &sum_max(@mut);
    ($Hcc_ref_sum,$Hcc_ref_max) = &sum_max(@Hcc_ref);
    ($Hcc_mut_sum,$Hcc_mut_max) = &sum_max(@Hcc_mut);

    #----- Print lines 
#    next if ($ref_sum <= 50  && $mut_sum <=50 );
    if ( $ref_sum < $mut_sum ) {
        my $ratio = (($Hq_ref_max == 0) ? $Hcc_ref_max : (int($Hcc_ref_max/$Hq_ref_max*100)/100) ) ;
        print "$Hq_ref_max\t$ref_max\t$Hcc_ref_max\t$ratio\t0\t";
    }
    else {
        my $ratio = (($Hq_mut_max == 0) ? $Hcc_mut_max : (int($Hcc_mut_max/$Hq_mut_max*100)/100) ) ;
        print "$Hq_mut_max\t$mut_max\t$Hcc_mut_max\t$ratio\t1\t";
    }
    print join("\t",@array),"\n";

#    print "$chr\t$pos\n";
}

sub number_series($$$$){
    my ($start,$from,$to,$step)= @_;
#    print "Step\t$from\n";
    my (@a,@b) = qw{}; # record number of field
    for my $i($from..$to){
       my $a = $start + $i*$step;
       my $b = $start + 1  + $i*$step;
       push (@a,$a);
       push (@b,$b);
#        print "OK\t$a\n";
    }
    return(\@a,\@b);
#    print "INTERNAL",@a;
}

sub sum_max(@){
    my @a = @_;
    #print join(" ",@a),"\n";
    my ($sum,$max) = qw{0 0};
    foreach(@a) {
       $sum += $_;
       $max = $_ if ( $_ > $max);
    }
    #print "$sum\t$max\n";
    return($sum,$max);
}
