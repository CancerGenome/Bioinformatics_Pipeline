perl  print_StepFour_Dep.pl - > StepFour.dependent.list 

sed -i 's/3067606/3079334/' StepTwo.dependent.list
sed -i 's/3067700/3079444/' StepThree.depedent.list
sed -i 's/3067970/3079471/; s/3067971/3079472/;s/3067972/3079473/;s/3067973/3079474/;s/3067974/3079475/;' StepFour.dependent.list
sed -i 's/3068680/3079482/' StepFive.dependent.list
seq 3079497 3079612 > StepSix.dependent.list 
