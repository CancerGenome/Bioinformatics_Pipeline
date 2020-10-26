#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: stat.sh, given a FMD short ID, output
#      Number of Female, Caussian, diagnose age(mean, std), no.fmd (mean, std), no.dissection(mean,std), no.aneurym(mean, std)
#
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 19 Jul 2019 11:42:42 AM EDT
#########################################################################
"
exit
fi
echo "No of Female:"
fetch.pl -q1 -d2  $1 ~/bin/FMD.all.sample.info | cut -f8 | sort | uniq -c # female 257
echo ""

echo "No of Caussian:"
fetch.pl -q1 -d2  $1 ~/bin/FMD.all.sample.info | cut -f10 | sort | uniq -c # Caussian 255
echo ""

echo "Diagnose age mean and std:"
fetch.pl -q1 -d2 -h $1 ~/bin/FMD.all.sample.info |awk '$6!="-"' | sed '1d' |datamash  mean 6 sstdev 6
echo ""

echo "No.fmd mean and std:"
fetch.pl -q1 -d2 -h $1 ~/bin/FMD.all.sample.info  | cut -f12-21,23-27 | sed 's/-/0/g' | sed '1d' | awk '{ for(i=1; i<=NF;i++) j+=$i; print j; j=0 }' | datamash mean 1 sstdev 1  # mean and std for no.fmd
echo ""

echo "No.dissection age mean and std:"
fetch.pl -q1 -d2 -h $1 ~/bin/FMD.all.sample.info  | cut -f45 - | awk '$1!="-"' | sed '1d' | datamash mean 1 sstdev 1  # no.dissection mean and std
echo ""

echo "No.aneurysm age mean and std:"
fetch.pl -q1 -d2 -h $1 ~/bin/FMD.all.sample.info  | cut -f29 - | awk '$1!="-"' | sed '1d' | datamash mean 1 sstdev 1  # no.aneurysm mean and std
