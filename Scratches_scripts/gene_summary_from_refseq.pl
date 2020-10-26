use warnings;
use strict;

my @comments = {};
my $tag = 0 ;
my $print  = 1 ;

while(1) {
    my $_ = <>;
    chomp $_;

    if(/^PRIMARY|^FEATURES/) {
        $tag = 0;
        next;
    }
    elsif(/\/gene="(.+?)"/) {
        if ($print) {
            print $1," ";
            print join(" ",@comments),"\n";
            @comments = {};
            $print = 0;
            next;
        }
    }
    elsif (/^COMMENT/) {
        $tag = 1;
        push(@comments,$_);
    }
    elsif($tag == 1 ) {
        push(@comments,$_);
    }
    elsif (/\/\//) {
        $print = 1;
    }
    elsif ($_ eq "") {
        last;
    }
}

=head
my $gene = {};
my $tag = {};
my $last = <>;
chomp $last;

open STDERR, ">gene_list";

while(<>) {
    chomp;
    if (/^DEFINITION/) {
        if(/\((.+?)\)/) {
            $gene = $1;
            print "$gene\_$last\n";
            print STDERR $gene,"\n";
        }
    }
    elsif(/(LOCUS|ACCESSION|VERSION|KEYWORDS|SOURCE|ORGANISM|COMMENT|PRIMARY|FEATURES)/){
        print "$gene\_$_\n";
        $tag = $1 ;
    }
    else {
        print "$gene\_$tag$_\n";
    }


    $last = $_ ;
}

close STDERR;
