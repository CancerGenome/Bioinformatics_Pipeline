#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/xiaozhu/bin/git.sh Version_Notes
#      Description:
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Tue 19 Jul 2022 11:18:34 PM EDT
#########################################################################
"
exit
fi

INPUT=$1
echo $INPUT

git add .
#git tag -a -F TAG
# this will automatically add and remove anything 
git commit -a 
git push
# Show all git tags
# git log --pretty=oneline
