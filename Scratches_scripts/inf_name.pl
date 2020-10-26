#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./inf_name.pl  
#
#  DESCRIPTION:  Get each name for id ,  name always include place year and so on
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  2009年05月03日 23时16分55秒
#===============================================================================

use strict;
use warnings;

while(<>){
chomp;
my $line = $_;
if ($line =~ /(>gi\|\d+\|gb\|.+\|)  # gi gb something
	.+   # other
	\((\w+\/\w+\/\d+\/(?:\d+\(\w+\)|\d+))                    # (A_something_93_98(H3N2))
	/x){                                        # End of match
print "$1\t$2\n";
}


}

