#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/json.sh -a
#      Description:
#      Process Google API return json file
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Fri 19 Jun 2020 10:00:31 AM EDT
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
	  jq '.items[].link,.items[].snippet,.items[].pagemap.metatags[]'
