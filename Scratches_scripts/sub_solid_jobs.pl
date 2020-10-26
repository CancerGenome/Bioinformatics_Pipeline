#!/usr/bin/perl
#Filename:
#Author:	Du Zhenglin
#EMail:		duzhl@big.ac.cn
#Date:		2008-9-26
#Modified:	2008-12-24
#Description: 
#the path for qsub & qstat should be motified before use
my $version=1.10;

use strict;
use Getopt::Long;


use FileHandle;

my %opts;
GetOptions(\%opts,"i=s","o:s","s","j:i","h");
if (!(defined $opts{i}) || defined $opts{h}) {			#necessary arguments
	&usage;
}

my $script_path="/share/disk2/bioinformatics/duzhl/bin/sub_solid_jobs.pl";

my $joblist=$opts{'i'};

my $logfile="cron.log";
if (defined $opts{l} && (-e $opts{l})) {
	$logfile=$opts{l};
}

my $tmpfile;
my $joblist_line_log=0;
my $jobid_log="";
my $line_counter=0;
my @jobid=();

my @info;
my $pbsfile;
my $sgefile="";
my $jobname;
my $jobout;
my $outpath;
my $user_id=`whoami`;
chomp($user_id);
my $flag=0;

my $qsubinfo="";
my %checkid;

my $qsub_path;
my $job_counter=0;

my @buffer;

#get the path of joblist file
unless (-e $joblist) {		#check if exist
	print "Err: JOB_LIST.txt doesn't exist.\n";
	exit();
}
unless ($joblist=~/^\//) {	#check absolute path
	print "Err: Please input the absolute path of JOB_LIST.txt.\n";
	exit();
}
if ($joblist=~/JOB_LIST\.txt/) {
	$outpath=$`;
}else{
	print "Err: Please give JOB_LIST.txt file\n";
	exit();
}
$logfile=$outpath.$logfile;
$tmpfile=$outpath."cron.tmp";

$ENV{"SGE_CELL"}="default";
$ENV{"SGE_ARCH"}="lx26-amd64";
$ENV{"SGE_EXECD_PORT"}="537";
$ENV{"SGE_QMASTER_PORT"}="536";
$ENV{"SGE_ROOT"}="/opt/gridengine";



#####check if the jobs already exits in crontab
my @lines=`crontab -l`;	
my $exist_flag=0;

for (my $i=0;$i<=$#lines ;$i++) {
	if ($lines[$i]=~/$joblist/) {
		$exist_flag=1;
		last;
	}
}

unless ($exist_flag) {

	if (-e $outpath."JOB_TREE.txt") {
		open JOBTMP,"<$joblist";
		while (<JOBTMP>) {
			push(@buffer,$_);
		}
		close(JOBTMP);
		open JOBTREE,"<$outpath"."JOB_TREE.txt";
		open JOBTMP,">$joblist";
		while (my $aline=<JOBTREE>) {
			if ($aline=~/^(\d+)/) {
				my $line_num=$1;
				my @info=split(/\t+/,$aline);
				@info=split(/,/,$info[1]);
				if ($#info >= 1) {
					print JOBTMP "00\techo \"waiting...\"\n";
					print JOBTMP $buffer[$line_num-1];
					print JOBTMP "00\techo \"waiting...\"\n";
				}else{
					print JOBTMP $buffer[$line_num-1];
				}
			}
		}
		close(JOBTMP);
		close(JOBTREE);
	}
	#exit();

	open TMP,">$tmpfile";
	for (my $i=0;$i<=$#lines ;$i++) {
		print TMP $lines[$i];
	}
	my $cmdline="*/1 * * * * perl $script_path -i $joblist ";
	if (defined $opts{j}) {
		$cmdline.="-j $opts{j} ";
	}
	$cmdline.=">> $outpath"."job.log\n";

	print TMP $cmdline;
	close(TMP);

	system("crontab $tmpfile");
	system("rm $tmpfile");
	print "New job submitted.\n";
}



#######read job log
if (-e $logfile) {
	open LOG,"<$logfile";
	while (my $aline=<LOG>) {
		chomp($aline);
		if ($aline=~/^FINISHED/) {
			my @lines=`crontab -l`;	#delete the finished job from crontab
			open TMP,">$tmpfile";
			for (my $i=0;$i<=$#lines ;$i++) {
				if ($lines[$i]=~/$joblist/) {
					next;
				}
				print TMP $lines[$i];
			}
			system("crontab $tmpfile");
			system("rm $tmpfile");
			exit();
		}
		if ($aline=~/^LINE: (\S+)/) {
			$joblist_line_log=$1;
		}elsif($aline=~/^JOBID: (\S+)/){
			$jobid_log=$1;
			@jobid=split(/;/,$jobid_log);
		}
	}
	close(LOG);
	for (my $i=0;$i<=$#jobid ;$i++) {
		$checkid{$jobid[$i]}="";
	}

	######check if jobs submitted were done
	#while (my $fh=FileHandle->new("$ENV{'SGE_ROOT'}/bin/$ENV{'SGE_ARCH'}/qstat |")) {

	my $fh=FileHandle->new("/opt/gridengine/bin/lx26-amd64/qstat |");
	while (<$fh>) {
		~s/^\s+//g;
		next if(/^\-+/ || /^job/);
		split;
		if (defined $checkid{$_[0]}) {
			exit();
		}
	}
	$fh->close;
	@jobid=();
}


#########go on with job_list file
open LOG,">$logfile";
open IN,"<$joblist" or die "can't open file $joblist\n";
while (my $aline=<IN>) {
	$line_counter++;
	if ($line_counter<=$joblist_line_log) {
		next;
	}
	chomp($aline);
	@info=split(/\t+/,$aline);

	if ($info[1]=~/\.sh$/) {
		$pbsfile=$info[1];
		open PBS,"<$pbsfile";
		$sgefile=substr($pbsfile,0,length($pbsfile)-3);
		$sgefile.="_sge.sh";
		open SGE,">$sgefile";	#convert to SGE shell files
		print SGE "#!/bin/bash\n";
		print SGE "\#\$ -S /bin/bash\n";
		print SGE "\#\$ -cwd\n";

		while (my $aline=<PBS>) {
			if ($aline=~/^#PBS -N (\S+)/) {
				$jobname=$1;
				print SGE "\#\$ -N $jobname\n";
			}elsif($aline=~/^#PBS -o (\S+)/){
				$jobout=$1;
				$jobout=~s/\'//g;
				print SGE "\#\$ -o $jobout\n";
			}elsif($aline=~/^#PBS -j /){
				print SGE "\#\$ -j y\n";
			}elsif($aline=~/^## Force all files to be group writable/){	#output the rest to sge shell file
				print SGE "\n$aline";
				while (my $aline=<PBS>) {
					if ($aline=~/^date/) {
						next;
					}
					print SGE $aline;
				}
			}
		}
		close(PBS);
		close(SGE);
		if (defined $opts{s}) {
			next;
		}
		print "qsub $sgefile\n";
		$qsubinfo=`/opt/gridengine/bin/lx26-amd64/qsub $sgefile`;
		if ($qsubinfo=~/Your job (\d+)/) {
			push(@jobid,$1);
		}
		$job_counter++;
		if (defined $opts{j}) {			#check the number of jobs submitted
			if ($job_counter >= $opts{j}) {
				$joblist_line_log=$line_counter;
				print LOG "LINE: $joblist_line_log\n";
				$jobid_log=join(";",@jobid);
				print LOG "JOBID: $jobid_log\n";
				exit();
			}
		}
	}elsif($info[1]=~/^echo "wait/){
		$joblist_line_log=$line_counter;
		print LOG "LINE: $joblist_line_log\n";
		$jobid_log=join(";",@jobid);
		print LOG "JOBID: $jobid_log\n";
		exit();
	}
}
print LOG "FINISHED\n";
#print "All jobs done.\n";


sub usage{
	print <<"USAGE";
Version $version
Usage:
	$0 -i <input file> 
options:
	-i input JOB_LIST.txt file
	-s only generate SGE scripts, don't submit jobs
	-l job log file(default cron.log)
	-j max number of jobs submitted once
	-h help
NOTE:
	JOB_LIST file must include the absolute path
USAGE
	exit(1);
}


