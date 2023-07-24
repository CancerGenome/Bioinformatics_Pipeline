#!/bin/bash
module load Bioinformatics 1>/dev/null 2>/dev/null
module load bedtools2 1>/dev/null 2>/dev/null
cut -f1-3 $@ | sort -k1V,1 -k2n,2 -k3n,3 | bedtools merge -i stdin | awk '{a+=($3-$2)}END{print  a}'
