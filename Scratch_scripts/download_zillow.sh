#!/bin/sh
zillow.py 48103; sleep 2
zillow.py 48104; sleep 2
zillow.py 48105; sleep 2
zillow.py 48130; sleep 2
zillow.py 48167; sleep 2
zillow.py 48168; sleep 2
zillow.py 48170; sleep 2
zillow.py 48187; sleep 2
zillow.py 48188; sleep 2
zillow.py 48374; sleep 2
zillow.py 48375; sleep 2
zillow.py 48304; sleep 2
zillow.py 48302; sleep 2
zillow.py 48098; sleep 2
zillow.py 48084; sleep 2
cat properties-48084.csv properties-48103.csv properties-48104.csv properties-48105.csv properties-48130.csv properties-48167.csv properties-48168.csv properties-48170.csv properties-48187.csv properties-48188.csv properties-48302.csv properties-48304.csv properties-48374.csv properties-48375.csv properties-48098.csv > Zillow.All
rm properties-48084.csv properties-48103.csv properties-48104.csv properties-48105.csv properties-48130.csv properties-48167.csv properties-48168.csv properties-48170.csv properties-48187.csv properties-48188.csv properties-48302.csv properties-48304.csv properties-48374.csv properties-48375.csv properties-48098.csv 
dos2unix Zillow.All
format_zillow.pl Zillow.All  > Zillow.clean.csv
gedit Zillow.clean.csv
