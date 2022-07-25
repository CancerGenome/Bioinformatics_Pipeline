#!/usr/bin/perl 
sub usage (){
    die qq(
#===============================================================================
#
#        USAGE:  ./fetch.pl <-q -d> -f -p <-c -n> <Query>  <Database> 
#
#  DESCRIPTION:  
#      general : -q '1,2,3' -d '1,2,3' Query: query file and Database : db file
#
#                -p : print query file [Default 0]
#                -f : print not exist data in query [Default 0]
#                -r : Repeat Model, Report all repeat combination, compatiable with -q -d -p 
#                -a : print all query, combine with -r
#                -h : print the header no matter which option
#
# variable num : -c : which field is changed, if means this field could be changed, 
#                     eg, query position is 100, then adjacent position [99-101] may be omitted,
#                     this filed must be Numeric
#                -n : must be used with -c option [Default 0]
#                     Query should be uniq, 
#
#       FORMAT:       Print Query first, then Database result
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  02/28/2011 
#===============================================================================

)
}
use strict;
use warnings;
use Getopt::Std;

our($opt_q,$opt_d,$opt_f,$opt_p,$opt_c,$opt_n,$opt_r,$opt_a,$opt_h);
$opt_n = 0 ;
getopts("q:d:fpc:n:rah");
$ARGV[0] || &usage();
my @q = split/\,/,$opt_q;
my @d = split/\,/,$opt_d;
my @var_field ;

#my $var_field = grep {$q[$_] == $opt_c } (0..$#q) if ($opt_c);

#print "Var_field\t$var_field\n";
foreach (@q) {
    $_ --;
}

foreach (@d) {
    $_ --;
}
if ($opt_c) {
    @var_field = split/\,/,$opt_c;
    foreach(@var_field) {
        $_ --;
    }
}

my %hash;
open (IN,"$ARGV[0]") ||  die "** Can not open $ARGV[0]\n";
open (IN2,"$ARGV[1]") or die "** Can not open $ARGV[1]\n";


if($opt_h){
	my $line2 = <IN2>;
	if(defined $opt_p){
		my $line1 = <IN>;
		chomp $line1;
		print $line1,"\t",$line2;
	}
	else{
		print $line2;
	}
}
#
# repeat model, report all repeat combination, both in query and database
 if ($opt_r){
	&repeat();
	exit(1);
 }

while(my $line = <IN>){
	#next if($line =~ /^#/);
    chomp $line;
    my @cur = split/\s+/,$line;
    if (!$opt_c) {
        $hash{join("\t",@cur[@q])} = $line ;
    }
    elsif ($opt_c) {

            $hash{join("\t",@cur[@q])} = $line ;
##           print join("\t",@cur[@q]),"\n";

      foreach my $var_field (@var_field) {
        my $tmp_change_field_value = $cur[$var_field];
#        print "tmp_value\t$tmp_change_field_value\n";

        for my $i(1..($opt_n)){
#            print "Origin\t$i\t",$cur[$var_field],"\n";
            $cur[$var_field] = $tmp_change_field_value + $i;
#            print "Change\t$i\t",$cur[$var_field],"\n";
            $hash{join("\t",@cur[@q])} = $line ;
##            print join("\t",@cur[@q]),"\n";

            $cur[$var_field] = $tmp_change_field_value - $i;
#            print "Change\t$i\t",$cur[$var_field],"\n";
            $hash{join("\t",@cur[@q])} = $line;
##            print join("\t",@cur[@q]),"\n";
            $cur[$var_field] = $tmp_change_field_value ;
#            print "Restore\t$cur[$var_field]\n";
        }
     }
    }
}
close IN;


while(my $line2 = <IN2>) {
	#next if($line2 =~ /^#/);
    chomp $line2;
    next if ($line2 eq "");
    my @F = split/\s+/,$line2;
    if (( $hash{ join ("\t",@F[@d]) } ) and !($opt_f) ){
        if ($opt_p) {
            print  $hash{ join ("\t",@F[@d]) },"\t"; # print query
        }
        print $line2,"\n"; # print db
    }
    elsif (!( $hash{ join ("\t",@F[@d]) } ) and $opt_f ){
        print $line2,"\n"; # print not
    }
#    else {
#        print "-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t$_\n";
#    }
}

sub repeat(){
my $colx = 0 ; # record number of column of first 
my $coly = 0 ; # record number of column of second 
my %print; # record whether print first file

while(my $line = <IN>){
    next if($line =~ /^#/);
    chomp $line;
    my @cur = split/\s+/,$line;
	$colx = $#cur +1 ; #record colnum number for first 
	#print STDERR "First\t",join("\t",@cur[@q]),"\n";
	push(@{$hash{join("\t",@cur[@q])}},$line);
	#push(@{$hash{'ALLDATA'}},$line);
}
close IN;
while(my $line = <IN2>){
    next if($line =~ /^#/);
    chomp $line;
    my @cur = split/\s+/,$line;
	#print STDERR $cur[$d[0]],"\n";
	#print STDERR @d,"\n";
	$coly = $#cur + 1; 
	if($hash{join("\t",@cur[@d])}){
#		print STDERR "Second\t",join("\t",@cur[@d]),"\n";
		my @print = @{$hash{join("\t",@cur[@d])}};
		for my $i(0..$#print){
			print "$print[$i]\t$line\n";
		}
		$print{join("\t",@cur[@d])} = 1; # record for printing;
	}
	else{
		print "-\t"x$colx,$line,"\n" if($opt_a);
	}
}
if($opt_a){
	for my $key(keys %hash){
		if(!$print{$key}){
			my @cache = @{$hash{$key}};
			for my $i(0..$#cache){
				print $cache[$i],"\t-"x$coly,"\n";
			}
		}	
	}
}
close IN2;
}

