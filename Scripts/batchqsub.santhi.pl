#!/usr/bin/perl 
sub usage (){
	die qq(
#===============================================================================
#
#        USAGE:  ./print_pbs.pl <INPUT> -t <hours> -n <number of threads> -m <memory> 
#                -s <Resubmit start line> 
#                -e <Resubmit end line> 
#                -i <resubmit these lines, start from 1,separte with comma>
#
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

our ($opt_t,$opt_n,$opt_m,$opt_s,$opt_e,$opt_i);
getopts("t:n:m:s:e:i:");
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

open IN,"$ARGV[0]";

while(<IN>)
{
next if (/^#/);
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
echo "$filename.$i.sh"
echo "Test job starting at `date`"
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
EOF

`chmod +x /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
#`qsub -cwd -N $filename\_$i -j y -o '$pwd/log/$filename.$i.log' -l vf=$opt_m /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
	if($select == 0 ){
		`qsub -N $i\_$filename -j oe -o '$pwd/log/$filename.$i.log' /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
		#print "A:$i\n";
	}elsif($select == 1){
		if(defined $opt_s and $i >= $opt_s and $i<= $opt_e){
		`qsub -N $i\_$filename -j oe -o '$pwd/log/$filename.$i.log' /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
			#print "B:$i\n";
		}elsif(exists $include{$i}){
		`qsub -N $i\_$filename -j oe -o '$pwd/log/$filename.$i.log' /home/yulywang/tmp/qsub_shell/$filename.$i.sh`;
			#print "C:$i\n";
		}
	
	}
	$i = $i + 1;
}
close OUT;
close BACKUP;
close IN;
#PBS -q mapG
