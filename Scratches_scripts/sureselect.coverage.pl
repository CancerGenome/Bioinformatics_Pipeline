UNFINISHED
#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./sureselect.coverage.pl  <pileup> <sureselect.map>
#
#  DESCRIPTION:  Used Sureselect map file to get coverage information
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  05/11/2011 
#===============================================================================

)
}
use strict;
use warnings;
$ARGV[0] || &usage();

my %hash;
my @chr = qw(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY chrM);
for my $i(0..$#chr){
    $hash{$i} = $i;
}

open F, $ARGV[0]|| die "Could not open A";
open R, $ARGV[1]|| die "Could not open B";
my ($f, $r);
my (@f, @r);
my ($total,$length); # total: record total coverage; length record total region length
$r =<R>;
@r = split /\s+/,$r;
$f =<F>;
@f = split /\s+/,$f;

while(1){
#    print "$f[0]\t$f[1]\t$hash{$f[0]}\t$r[0]\t$r[1]\t$hash{$r[0]}\t";
    if ($hash{$f[0]} == $hash{$r[0]}){
        if($f[1] == $r[1]){
            &print_f(); 
#            &print_chr_pos();
            &read_r();
            &read_f();
        last unless(defined $r);
        last unless(defined $f);
        }
        elsif ($f[1] >$r[1]){
            &read_r();
        last unless(defined $r);
        }
        elsif ($f[1]< $r[1]){
            &read_f();
        last unless(defined $f);
        }
    }
    elsif($hash{$f[0]} > $hash{$r[0]}){
        &read_r();
        last unless(defined $r);
    }#els    
    elsif($hash{$f[0]} < $hash{$r[0]}){
        &read_f();
        last unless(defined $f);
    }

}


#------ sub
sub print_f(){
    #  if ($f[6]>0||$f[7]>0||$f[8]>0||$f[5]>0||$r[6]>0||$r[7]>0||$r[8]>0||$r[5]>0){
    #    my @new = @f[0,1,2,3,5,6,7,8];
    my @new = @f ;
        push (@new,@r[3,4,5,6,7,8,9,10,11]);
        print join ("\t",@new),"\n";
        #}

}
sub print_chr_pos(){
    print $f[0],"\t",$f[1],"\n";
}
sub read_f(){
    $f = <F>;
    chomp $f;
    @f = split /\s+/,$f;
}
sub read_r(){
    $r = <R>;
    chomp $r;
    @r = split /\s+/,$r;
}

