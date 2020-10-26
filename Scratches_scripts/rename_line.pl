#!/usr/bin/perl 
perl -ae '{@a=`ls rc.*`;foreach(@a){chomp;$a=$_;$_=~s/rc/R1/; print "mv $a\t$_\n"}}'
