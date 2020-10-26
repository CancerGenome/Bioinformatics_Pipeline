#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./print_pbs.pl <INPUT> -t <hours> -n <number of threads> -m <memory> -r <repeat qsub> -d <debug que>
#
#  DESCRIPTION:  Print PBS head file and others
#                r: re-qusb script, which have been fully prepared with all enviromental variable
#                d: debug mode, will be the fastest priority, only one job allowed
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

our ($opt_t,$opt_n,$opt_m,$opt_r,$opt_d);
getopts("t:n:m:rd");
if (not defined $opt_t){
	$opt_t = 5; # default 5 hours
}
if (not defined $opt_n){
	$opt_n = 1; # default 1 thread
}
if (not defined $opt_m){
	$opt_m = 1; # default 5 Giga
}

# define queue
my $queue = "standard";
if(defined $opt_d){
	$queue = "debug";
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
	#`qsub -N w_$filename -j oe -o '$pwd/log/$filename.log' $ARGV[0]`;
	`sbatch --job-name=$filename --output '$pwd/log/$filename.log'  /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
	exit 1;
}

open BACKUP, ">>/home/yulywang/bin/qsub.backup";
print BACKUP `date`;
print BACKUP "$pwd/log/$filename.log\n";
print BACKUP "Memory: $opt_m, CPU: $opt_n, Time: $opt_t\n";

if(-d "$pwd/log"){
	print "Exists Log\n";
}
else{
	`mkdir $pwd/log`;
	print "Create Log Here\n";
}

open OUT,">/home/yulywang/tmp/qsub_shell/$filename.$i.sh";
print OUT <<EOF;
#!/bin/sh
#
#This is the job name.  Feel free to change this at will to whatever you need. PBS -N, greatlake SBATCH -J, https://arc-ts.umich.edu/migrating-from-torque-to-slurm/
#SBATCH --job-name=$i.$filename
#This tells the scheduler what account to use.  Do not change. flux PBS -A, greatlake SBATCH -A
#View accounts you can submit to	sacctmgr show assoc user=uniquename
#View users with access to an account	sacctmgr show assoc account=<account>
#View default submission account and wckey	sacctmgr show User <account>
#SBATCH --account=sganesh99
#Available partitions: standard (default), gpu (GPU jobs only), largemem (large memory jobs only), viz, debug, standard-oc (on-campus software only)
#SBATCH --partition=$queue
#This denotes the number of nodes and processors that the job should be run on.
#You should change walltime as you see fit, find out how much you use, and then add 10-15%.
#It is denoted by hh:mm:ss or dd-hh:mm:ss
#You can set your start time by using --begin=2020-12-25T12:30:00
#You will be able to set dependencies by using sbatch --dependency=afterany:123213 Job2.sh where 123213 is your dependent job id, Job2.sh is the subsequent jobs.
#afterany indicates that Job2 will run regardless of the exit status of Job1, i.e. regardless of whether the batch system thinks Job1 completed successfully or unsuccessfully.
# mem is per nodes mem
#SBATCH --nodes=1
#SBATCH --cpus-per-task=$opt_n
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=$opt_m\g
#SBATCH --time=$opt_t:00:00

#The next two denotes the email address to send jobs to, and under what conditions to send that email.
#This line says (a) send email if the job fails, (b) when the job starts, and (e) when the job ends.
#SBATCH --mail-user=yulywang\@umich.edu
#SBATCH --mail-type=END,FAIL
#This line sends all environment variables on the login node.
#SBATCH --export=ALL
#SBATCH --output='$pwd/log/$filename.log'
#
#Your shell script and commands goes here.
#
export HOME=/home/yulywang
source /home/yulywang/.bashrc
cd $pwd
 if [ -d log ]; then 
     echo "exits log"
 else mkdir log
 fi
echo "$filename"
echo "Test job starting at `date`"
SECONDS=0
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
duration=\$SECONDS
echo "\$duration seconds elapsed."
EOF
`chmod +x /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
#`qsub -N $filename -j oe -o '$pwd/log/$filename.log'  /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
`sbatch --job-name=$filename --output '$pwd/log/$filename.log'  /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;

close OUT;
close BACKUP;
close IN;
#SBATCH -q mapG
