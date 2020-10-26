#!/bin/bash
ps hax -o rss,user | grep yulywang | awk '{a[$2]+=$1;}END{for(i in a)print i" "int(a[i]/1024+0.5);}' | sort -rnk2
