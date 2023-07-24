#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./check.pl  
#
#  DESCRIPTION:  To check your gmail whether have new messages
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#      COMPANY:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  2009年04月01日 11时17分51秒
#===============================================================================

use strict;
use warnings;
#$ARGV[1]||die "\n\t\tperl $0 <username><passwd>\n\n";
#my ($usr,$passwd) =($ARGV[0],$ARGV[1]);
my ($usr,$passwd) =("wangyu.bgi","123qwe");
system("wget --secure-protocol=TLSv1 https://$usr:$passwd\@mail.google.com/mail/feed/atom");
open IN,"atom";
my (@from,@name,@title,@message);
while(<IN>){
	chomp;
	if (/\<title\>([^@]+)\<\/title\>/){
		push @title,$1;
	}
	elsif (/\<name\>([^@]+)\<\/name\>/){
		push @name,$1;
	}
	elsif (/\<email\>(.+)\<\/email\>/){
		push @from,$1;
	}
	elsif (/\<summary\>(.+)\<\/summary\>/){
		push @message,$1;
	}
}
#----PRINT GMAIL
if (!@message) {
	print "No messsage\n";
}
for my $i(0..$#message){
	print <<EOF;
---- This is Message $i ----
From :  $name[$i]  $from[$i]
Title:  $title[$i]
Content:
		$message[$i]

EOF
}
system("rm atom");
