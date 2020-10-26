#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./print_pbs.pl <INPUT> -t <hours> -n <number of threads> -m <memory> -r <repeat qsub>
#
#  DESCRIPTION:  Print PBS head file and others
#                r: re-qusb script, which have been fully prepared with all enviromental variable
#
#       AUTHOR:  Wang yu , wangyu.big at gmail.com
#    INSTITUTE:  BIG.CAS
#      CREATED:  09/25/2009 
#===============================================================================

		  )
}
use strict;
use warnings;
use Getopt::Std;

our ($opt_t,$opt_n,$opt_m,$opt_r);
getopts("t:n:m:r");
if (not defined $opt_t){
	$opt_t = 10; # default 5 hours
}
if (not defined $opt_n){
	$opt_n = 1; # default 1 thread
}
if (not defined $opt_m){
	$opt_m = 5; # default 5 giga
}

my $pwd=`pwd`;
chomp $pwd;
$ARGV[0]|| &usage();
my @a  = split/\//,$ARGV[0];
my $filename = pop @a;
my $i = 1 ;

if ($opt_r){ # re-qusb script, which have been fully prepared with all enviromental 
	`date >> /home/yulywang/bin/qsub.backup `;
	`cat $ARGV[0] >> /home/yulywang/bin/qsub.backup `;
	`qsub -N w_$filename -j oe -o '$pwd/log/$filename.log' $ARGV[0]`;
	exit 1;
}

open BACKUP, ">>/home/yulywang/bin/qsub.backup";
print BACKUP `date`;
print BACKUP "$pwd/log/$filename.log\n";
print BACKUP "Memory: $opt_m, CPU: $opt_n, Time: $opt_t\n";

open OUT,">/home/yulywang/tmp/qsub_shell/$filename.$i.sh";
print OUT <<EOF;

#!/bin/bash
#
#This tells the scheduler what account to use.  Do not change.
#PBS -A sganesh_fluxod
#This is the job name.  Feel free to change this at will to whatever you need.
#PBS -N $i.$filename
#This denotes the queue that the job should be run in.  Do not change if you want to use the flux dedicated nodes
#PBS -q fluxod
#The next two denotes the email address to send jobs to, and under what conditions to send that email.
#This line says (a) send email if the job fails, (b) when the job starts, and (e) when the job ends.
#PBS -m ae
#Output input/output files
#PBS -j oe
#This line sends all environment variables on the login node.
#PBS -V
#This denotes the number of nodes and processors that the job should be run on.
#You should never change the processors per node from the default for the
#cluster, unless you only need one or two cores.  The max for ppn is currently 12.
#You should change walltime as you see fit, find out how much you use, and then add 10-15%.
#It is denoted by hh:mm:ss, and hours can be no more than 376 (or 28 days).
#PBS -l nodes=1:ppn=$opt_n,pmem=$opt_m\gb
#PBS -l walltime=$opt_t:00:00
#PBS -l qos=flux
#Your shell script and commands goes here.
#
export HOME=/home/yulywang
source /home/yulywang/.bashrc
cd $pwd
 if [ -d log ]; then 
     echo "exits"
 else mkdir log
 fi
echo "$filename.sh"
echo "Test job starting at `date`"
EOF

open IN,"$ARGV[0]";
while(<IN>)
{
next if (/^#/);
    print BACKUP;
	print OUT;
}
print OUT <<EOF;

echo "Test job finished at `date`"
EOF
`chmod +x /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
`qsub -N $filename -j oe -o '$pwd/log/$filename.log'  /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;

close OUT;
close BACKUP;
close IN;
#PBS -q mapG
