# Step 1 Time
echo "Step 1 Time min max sum mean"
grep Real\ time StepOne.bwa*log| cut -d\; -f1  | cut -d\: -f3 | awk '{print $1/3600}' | datamash min 1 max 1 sum 1 mean 1
# Step 2 Time
echo "Step 2 Time "
grep Elapsed StepTwo_MarkDuplication.sh.*log | grep -v INFO | awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
# Step 3 Total Time
echo "Step 3 Total Time"
grep Elapsed StepThree_BQSR_GVCF*log | grep -v ProgressMeter | grep BaseRecalibrator | awk '{print $(NF-1)}' > 1
grep Elapsed StepThree_BQSR_GVCF*log | grep -v ProgressMeter | grep ApplyBQSR | awk '{print $(NF-1)}' > 2 
grep Elapsed StepThree_BQSR_GVCF*log | grep -v ProgressMeter | grep haplotypecaller | awk '{print $(NF-1)}' > 3
paste 1 2 3 > all
awk '{print $1+$2+$3}' all | datamash min 1 max 1 sum  1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
# Step 3 each time
echo "Step 3 Step Each Time"
grep Elapsed StepThree_BQSR_GVCF*log | grep -v ProgressMeter | grep BaseRecalibrator | awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
grep Elapsed StepThree_BQSR_GVCF*log | grep -v ProgressMeter | grep ApplyBQSR | awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
grep Elapsed StepThree_BQSR_GVCF*log | grep -v ProgressMeter | grep haplotypecaller | awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
# Step 4 and 5 and 6 each time
echo "Step 4 and 5 and 6 Each Time"
grep Elapsed StepFour_CombineGVCF.sh.*log | grep -v Meter |awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
grep Elapsed StepFive_Combine*log | grep -v Meter |awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'
grep Elapsed StepSix_GenotypeGVCF.sh.*log | grep -v Meter |awk '{print $(NF-1)}'| datamash min 1 max 1 sum 1 mean 1 | awk '{print $1/60,$2/60,$3/60,$4/60}'

echo "Step 3, 4 and 5 and 6 Memory Range"
grep -i TotalMemory StepThree_BQSR_GVCF.sh.*log | cut -d\= -f2  | datamash min 1 max 1
grep -i TotalMemory StepFour_CombineGVCF.sh.*log| cut -d\= -f2  | datamash min 1 max 1
grep -i TotalMemory StepFive_CombineGVCF_Merge.sh.*log| cut -d\= -f2  | datamash min 1 max 1
grep -i TotalMemory StepSix_GenotypeGVCF.sh.*log| cut -d\= -f2  | datamash min 1 max 1
