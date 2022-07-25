#!/bin/bash
if [ $# -le 0 ] 
then echo "
#########################################################################
#      USAGE: /home/yulywang/bin/burdentest_summary.sh -a
#      Description:
#      For adult result, summarize the top genes
#                  
#      Author: Wang Yu
#      Mail: yulywang@umich.edu
#      Created Time: Tue 04 Aug 2020 09:44:22 AM EDT
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
DIR=`pwd`
#ls -d adult* | sed 's/\///'| xargs -i echo mkdir $DIR/{}/PNG\; cd $DIR/{}/PNG\; Rscript ~/bin/Combine_Burdentest_Syn.R {} \;  | sh 
# Summary of the adult top genes
ls -d adult* | sed 's/\///'| xargs -i echo mkdir $DIR/{}/PNG\; cd $DIR/{}/PNG\; sh ~/bin/burdentest_summary.sh.combine {} \;  | sh 
cat adult_matchPC/PNG/SignificantGene.Output adult_dissection_matchPC/PNG/SignificantGene.Output adult_aneurysm_matchPC/PNG/SignificantGene.Output adult_dis_vs_nodis/PNG/SignificantGene.Output adult_ane_vs_noane/PNG/SignificantGene.Output  |cut -f2- > Adult.All
grep -v Category Adult.All > Adult.TopGene.forexcel

# Summary for var details 
grep \. adult_[adm]*/PNG/SignificantGene.CaseHigh | sed 's/\/PNG\/SignificantGene.CaseHigh:/\t/;s/_matchPC//;' > Adult.burdentest.forexcel
# Summary for fibrillar collagen or TGFB genes
grep -Eiw 'FIBRILLAR_COLLAGEN|LDS_SIX_GENE' ~/bin/fmd.pathway.gene.list | cut -f3- | GapTrans -tn - |awk 'BEGIN{print "Gene"}{print $1}' > TGFB_Fibril.list
grep \. adult_[adm]*/All/*.burden.forexcel |  sed 's/:/\t/' | sed 's/\//\t/' | cut -f1,3- | fetch.pl -h -q1 -d2 TGFB_Fibril.list - | sed 's/_matchPC//'> TGFB_Fibril
grep -Eiw 'FIBRILLAR_COLLAGEN|LDS_SIX_GENE' adult_[adm]*/All/pathway.forexcel |  sed 's/:/\t/' | sed 's/\//\t/' | cut -f1,3- | sed 's/_matchPC//'>> TGFB_Fibril
grep \. adult_[adm]*/Deleterious/*.burden.allfisher.forexcel | sed 's/:/\t/' | sed 's/\//\t/' | cut -f1,3- | fetch.pl -h -q1 -d2 TGFB_Fibril.list - | sed 's/_matchPC//' > TGFB_Fibril.del
grep -Eiw 'FIBRILLAR_COLLAGEN|LDS_SIX_GENE' adult_[adm]*/Deleterious/pathway.forexcel | sed 's/:/\t/' | sed 's/\//\t/' | cut -f1,3- | sed 's/_matchPC//' >> TGFB_Fibril.del
