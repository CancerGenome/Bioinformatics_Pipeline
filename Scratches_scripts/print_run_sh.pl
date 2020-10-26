#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./a.pl  
#
#  DESCRIPTION:  
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  08/17/2009 06:28:25 PM
#===============================================================================

use strict;
use warnings;

my @file = `ls x*`;
foreach my $file (@file){
	chomp $file;
	open OUT, ">pvalue.$file.r";
print OUT <<EOF;

rm(list=ls(all=TRUE))
a=read.table("$file")
rec=rep(0,1)
for (i in 1:length(a\$V1)){
	rec[1]=fisher.test(matrix(c(a\$V1[i],a\$V2[i],a\$V3[i],a\$V4[i]),nrow=2))
	write.table(rec[1],"$file.pvalue",row.names=FALSE,col.names=FALSE,sep="\\n",append=TRUE)
}

EOF
print "Rscript pvalue.$file.r&\n";
}
