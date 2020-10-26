#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: print_100.sh -a
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 17 Jul 2020 10:33:27 AM EDT
#########################################################################
"
exit
fi

while getopts ":a" opt; do
  case $opt in
    a)
      echo "-a was triggered!" >&2 
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2 
      ;;
  esac
done

awk '{print FILENAME"\t"$0}' $1 
