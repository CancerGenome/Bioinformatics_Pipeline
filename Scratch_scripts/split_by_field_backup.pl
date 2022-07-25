#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./sel_sam.pl <Input File> <Field number> <Prefix_out> 
# 
#  DESCRIPTION:  Split sam file according chromosome 
#        Field number start from 1 
#            
#       Input_file and field_number is required. Prefix default "x"            
#
#       AUTHOR:  Wang yu , wangyu.big\@gmail.com
#      COMPANY:  BIG.CAS
#      CREATED:  08/28/2009 03:52:35 PM
#===============================================================================

          )
}
use strict;
use warnings;
$ARGV[1]|| &usage();
$ARGV[2]||($ARGV[2]="x");
use FileHandle;
my %handle;
my @name;

if ($ARGV[3]){
    open IN, $ARGV[3];
    while(my $line=<IN>){
        chomp $line;
        my @a = split/\s+/,$line;
        push (@name,@a);
    }
    close IN;
}

#else {
#@name=`cut -f$ARGV[1] $ARGV[0]|/share/disk6-4/wuzhy/wangy/bin/statis_uniq.pl|cut -f1`;
#}
chomp @name;
=head
for my $n (@name){  # open file handle
    my $a;
    $ARGV[2] ? ($a.=$ARGV[2]."_".$n) : ($a=$n);
    my $fh = FileHandle->new(">$a");
    $handle{$n}= $fh;
}
=cut
#print Dumper(%handle);
open IN2,$ARGV[0];
while(<IN2>){
    chomp;
    split;
    my $name = $_[$ARGV[1]-1];
    if (not defined $handle{$name}) {
        my $a = $ARGV[0].".".$name;
        my $fh2 = FileHandle->new(">$a");
        $handle{$name} = $fh2;
    }
    my $fh = $handle{$_[$ARGV[1]-1]};
        print $fh ($_,"\n");

}

