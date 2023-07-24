#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./print_pbs.pl <INPUT> -t <hours> -n <number of threads> -m <memory> -d (dependency FILE)
#                -s <Resubmit start line> 
#                -e <Resubmit end line> 
#                -i <resubmit these lines, start from 1,separte with comma>
#                -d: dependency job id, one each line after they are successsuflly exectured, NA means no need to dependency
#  DESCRIPTION:  Print PBS head file and others
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

our ($opt_t,$opt_n,$opt_m,$opt_s,$opt_e,$opt_i,$opt_d);
getopts("t:n:m:s:e:i:d:");
if (not defined $opt_t){
	$opt_t = 5; # default 5 hours
}
if (not defined $opt_n){
	$opt_n = 1; # default 1 thread
}
if (not defined $opt_m){
	$opt_m = 4; # default 5 giga
}
my $select = 0; # define whether to submit all jobs or select 
if( (defined $opt_s and not defined $opt_e) or (defined $opt_e and not defined $opt_s) ){
	die "Option -S and -E should defined at the same time\n";
}
if(defined $opt_s){
	$select = 1;
}

my @Dep;
if(defined $opt_d){
	open IN2, "$opt_d";
	while (my $line = <IN2>){
		chomp $line;
		push(@Dep, $line);
	}
}

my %include; # record which jobs to submit
if(defined $opt_i){
	$select = 1;
	my @I = split/,/,$opt_i;
	foreach my $i(@I){
		#print "E:$e\n";
		$include{$i} = 1; # record exclude number
	}
}

my $pwd=`pwd`;
chomp $pwd;
$ARGV[0]|| &usage();

my $i = 1;
my $filename;
my @a = split/\//,$ARGV[0];
$filename = pop @a;

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

open IN,"$ARGV[0]";

while(<IN>)
{
next if (/^#/);
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
#SBATCH --partition=standard
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
echo "$filename.$i.sh"
echo "Test job starting at `date`"
SECONDS=0
EOF

	if($select == 0 ){
		print BACKUP;
	}elsif($select == 1){
		if(defined $opt_s and $i >= $opt_s and $i<=$opt_e){
			print BACKUP;
		}elsif(exists $include{$i}){
			print BACKUP;
		}
	}
		print OUT;

print OUT <<EOF;
echo "Test job finished at `date`"
duration=\$SECONDS
echo "\$duration seconds elapsed."
EOF

`chmod +x /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
	if($select == 0 ){ # handle all samples

			if(defined $opt_d and $Dep[$i-1] ne "NA"){ # $i is starting from 1
				`sbatch --job-name=$i\_$filename --output '$pwd/log/$filename.$i.log' --dependency=afterok:$Dep[$i-1] /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
				#print "A: sbatch --job-name=$i\_$filename --output '$pwd/log/$filename.$i.log' --dependency=afterok:$Dep[$i-1] /home/yulywang/tmp/qsub_shell/$filename.$i.sh\n";
			}else{
				`sbatch --job-name=$i\_$filename --output '$pwd/log/$filename.$i.log'  /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
			}
	}elsif($select == 1){ # handle select lines
		if(  (defined $opt_s and $i >= $opt_s and $i<= $opt_e) or  exists $include{$i} ){

			if(defined $opt_d and $Dep[$i-1] ne "NA"){ # $i is starting from 1
				`sbatch --job-name=$i\_$filename --output '$pwd/log/$filename.$i.log' --dependency=afterok:$Dep[$i-1] /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
				#print "B: sbatch --job-name=$i\_$filename --output '$pwd/log/$filename.$i.log' --dependency=afterok:$Dep[$i-1] /home/yulywang/tmp/qsub_shell/$filename.$i.sh\n";
			}else{
				`sbatch --job-name=$i\_$filename --output '$pwd/log/$filename.$i.log'  /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
			} # end else
		} #end if 
	} # end if select
	$i = $i + 1;
}
close OUT;
close BACKUP;
close IN;
#PBS -q mapG
