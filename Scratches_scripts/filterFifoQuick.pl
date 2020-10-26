#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./filterFifoQuick.pl  -i <input> -c <command line>
#
#  DESCRIPTION:  Must be doulbe data
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  03/31/2011 
#===============================================================================

)
}
use strict;
#use warnings;
use Getopt::Std;
our($opt_i,$opt_c);
getopts("i:c");

if (not defined $opt_i) {
    $ARGV[0] || &usage();
}

my @list;
open IN,$opt_i;

while(<IN>){
    print $_ if (defined $opt_c);
    chomp;
    split/\=/;
    push(@list,$_[0]);
}
#print join("\n",@list),"\n";

my $num  = 0;
print "rm ",join(" ",$num+1..$num+$#list-1),"\n";
print "mkfifo ",join(" ",$num+1..$num+$#list-1),"\n";
push(@list,1+$num);
while ($#list > 1 ) {
     @list = &process(@list);
#    print join("\t",@list),"\n";
}
sub process(@) {
    my @array = @_;
    my $pos = splice(@array,-1);
    my @return;
    for my $i(0..int($#array/2) ) {
        if ($list[$i*2] =~ /HCC/ ) {
            print <<EOF;
                bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 <(\$$list[$i*2]) <(\$$list[$i*2+1])" | perl -ane '{my \@a = grep {\$F[\$_] =~ /chr/} (0..\$#F); \$F[0] = \$F[\$a[0]]; \$F[1] = \$F[\$a[0]+1]; \$F[2] = \$F[\$a[0]+2]; print join(\"\\t\",\@F),\"\\n\"; }' > $pos &
EOF
}
else {
    print <<EOF;
        bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 $list[$i*2] $list[$i*2+1] " | perl -ane '{my \@a = grep {\$F[\$_] =~ /chr/} (0..\$#F); \$F[0] = \$F[\$a[0]]; \$F[1] = \$F[\$a[0]+1]; \$F[2] = \$F[\$a[0]+2]; print join(\"\\t\",\@F),\"\\n\"; }' > $pos &
EOF
}
        push(@return,$pos);
        $pos ++;
    }
    return(@return,$pos);
}

=head
while($#list >1) {
    print "filter -k en -b -c -d "-" -a A,M,1,2 $list[$i] $list[$i+1] > $fifo &\n";
    $fifo ++ ;
}
=cut


#bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 <(\$$list[$i*2]) <(\$$list[$i*2+1]) | perl -ane '{my \@a = grep {\$F[\$_] =~ /chr/} (0..\$#F); \$F[0] = \$F[\$a[0]]; \$F[1] = \$F[\$a[0]+1]; \$F[2] = \$F[\$a[0]+2]; print join(\\\"\\\\t\\\",\@F),\\\"\\\\n\\\"; }' "> $pos &
#bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 <(\$$list[$i*2]) <(\$$list[$i*2+1])" | perl -ne '{ if (/^chr/) {print \$_;} else {\@F = split/\\s+/,\$_; my \@a = grep {\$F[\$_*10] =~ /chr/} (0..int(\$#F/10)); \$F[0] = \$F[\$a[0]]; \$F[1] = \$F[\$a[0]+1]; \$F[2] = \$F[\$a[0]+2]; print join(\"\\t\",\@F),\"\\n\"; }  }' > $pos &
#bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 $list[$i*2] $list[$i*2+1] | perl -ane '{my \@a = grep {\$F[\$_] =~ /chr/} (0..\$#F); \$F[0] = \$F[\$a[0]]; \$F[1] = \$F[\$a[0]+1]; \$F[2] = \$F[\$a[0]+2]; print join(\"\\t\",\@F),\"\\n\"; }' "> $pos &
#bash -c "filter  -k en -b -c -d'-' -a O,M,1,2 $list[$i*2] $list[$i*2+1] " | perl -ne '{ if (/^chr/) {print \$_;} else {\@F = split/\\s+/,\$_; my \@a = grep {\$F[\$_*10] =~ /chr/} (0..int(\$#F/10)); \$F[0] = \$F[\$a[0]]; \$F[1] = \$F[\$a[0]+1]; \$F[2] = \$F[\$a[0]+2]; print join(\"\\t\",\@F),\"\\n\"; }  }' > $pos &
