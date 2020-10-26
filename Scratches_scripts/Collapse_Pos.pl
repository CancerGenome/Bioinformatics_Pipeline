#!/usr/bin/perl -w
sub usage (){
    die qq(
#===========================================================================
#        USAGE:Collapse_Pos.pl  -h
#        DESCRIPTION: -h : Display this help
#        -p: position column, default 6 (this is the format after filter_pathoV3)
#        -s: sample column, default 84 (this is the format after call_header2)
#
#        Design for pull down the detailed gene information for FMD
#        Should combine with call_header2
#        Dir: ~/FMD/anno/TLN1
#        Author: Wang Yu
#        Mail: yulywang\@umich.edu
#        Created Time:  Mon 03 Jun 2019 03:18:40 PM EDT
#===========================================================================
)
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h,$opt_p,$opt_s);
getopts("hp:s:");
my $pos_col = 5;
my $sam_col = 83;
if(defined $opt_p){
	$pos_col = $opt_p - 1;
}
if(defined $opt_s){
	$sam_col = $opt_s - 1;
}
#print "$pos_col\t$sam_col\n";

# Store all sample infor as HASH
my %id;
my %gender;
my %age;
my %role;
my %relative;
while(my $line = <DATA>){
	my @F = split/\s+/,$line;
	$gender{$F[0]} = $F[1];
	$id{$F[0]} = $F[2];
	$age{$F[0]} = $F[3];
	$role{$F[0]} = $F[4];
	$relative{$F[0]} = $F[5];
}

my $line = <>;
chomp $line;
print $line,"\tSample_All\tPed\tCase\tCtrl\tOther";
my $pre_pos = 0; 
my $ped = 0 ;
my $ad = 0 ;
my $ctrl = 0 ;
my $other = 0 ;

while(my $line = <>){
	my @F = split/\s+/,$line;
	#print $F[$sam_col],"\t",$sam_col,"\n";
	my @G = split/\=/,$F[$sam_col];
	#print $role{$G[0]},"\n";


	# Collapse Here
	if($F[$pos_col] eq $pre_pos){ # collapse
		&print_current_ID($G[0],$G[1]);
		$pre_pos = $F[$pos_col];
	}
	else{
		# print ped, ad and ctrol number if posssible
		if($ped + $ad+ $ctrl + $other > 0 ){
			print "\t$ped\t$ad\t$ctrl\t$other\n";
			$ped = 0 ;
			$ad = 0 ;
			$ctrl = 0;
			$other = 0;
		}else{
			print "\n";
		}

		print join("\t",@F[0..($sam_col-1)]),"\t";
		&print_current_ID($G[0],$G[1]);
		$pre_pos = $F[$pos_col];
	}
	
	
	# Count each category
	if($role{$G[0]} eq "ped"){
		$ped++;
	}elsif($role{$G[0]} eq "adult"){
		$ad++;
	}elsif($role{$G[0]} eq "ctrl"){
		$ctrl++;
	}else{
		$other++;
	}

}
print "\t$ped\t$ad\t$ctrl\t$other\n"; # last line

sub print_current_ID($$){
	my $data  = shift;
	my $gt = shift;
	if($id{$data}){
		print $id{$data};
		#print ",$gt";
        
		if($role{$data} eq "ped" and $relative{$data} eq "-"){
			print "($role{$data});";
		}elsif($role{$data} eq "ped" and $relative{$data} ne "-"){
			print "($role{$data},$relative{$data});";
		}elsif($relative{$data} ne "-"){
			print "($relative{$data});";
		}else{
			print ";";
		}
	}else{
		print "-";
	}
}

__DATA__
Sample	Gender	ShortID	Age	role	IBD(IBD_PIHAT(0.1))
UMAD-1.121294	F	AD-0001	69	adult	-
UMAD-3.121259	F	AD-0003	55	adult	Dup_of_AD-0013,Siblings_of_AD-0004
UMAD-4.121240	F	AD-0004	58	adult	Siblings_of_AD-0003,Siblings_of_AD-0013
UMAD-13.121639	F	AD-0013	54	adult	Dup_of_AD-0003,Siblings_of_AD-0004
UMAD-14.121622	F	AD-0014	43	adult	-
UMAD-20.121682	F	AD-0020	56	adult	-
UMAD-21.121463	F	AD-0021	33	adult	-
UMAD-22.121811	F	AD-0022	42	adult	-
AD-0025.176082	F	AD-0025	3	ped	Son_of_AD-0028,Son_of_AD-0029
AD-0028.175537	M	AD-0028	26	ped_family	Father_of_AD-0025
AD-0029.175585	F	AD-0029	26	ped_family	Mother_of_AD-0025
UMAD-30.121526	F	AD-0030	57	adult	Daughter_of_AD-0117,Dup_of_CCF-0015
UMAD-34.121730	F	AD-0034	55	adult	-
UMAD-39.121206	F	AD-0039	40	adult	Daughter_of_AD-0054,Dup_of_CCF-0126,Siblings_of_CCF-0139
UMAD-41.121620	F	AD-0041	63	adult	-
UMAD-42.121311	F	AD-0042	56	adult	-
UMAD-46.121238	F	AD-0046	48	adult	Dup_of_CCF-0012
UMAD-47.121436	F	AD-0047	40	adult	-
UMAD-48.128726	F	AD-0048	53	adult	-
AD-0049.175579	F	AD-0049	8	ped	Daughter_of_AD-0050,Daughter_of_AD-0388,Dup_of_AD-0049
UMAD-49.121601	F	AD-0049	8	ped	Daughter_of_AD-0050,Daughter_of_AD-0388,Dup_of_AD-0049
AD-0050.175563	F	AD-0050	13	ped	Dup_of_AD-0050,Mother_of_AD-0049
UMAD-50.121577	F	AD-0050	13	ped	Dup_of_AD-0050,Mother_of_AD-0049
UMAD-54.121209	F	AD-0054	55	adult	Mother_of_AD-0039,Mother_of_CCF-0126,Mother_of_CCF-0139
UMAD-55.128552	F	AD-0055	50	adult	-
UMAD-56.121343	F	AD-0056	42	adult	-
AD-0057.175567	F	AD-0057	69	adult	-
UMAD-59.121735	F	AD-0059	53	adult	-
UMAD-60.121453	F	AD-0060	42	adult	-
UMAD-63.128716	F	AD-0063	39	adult	-
UMAD-69.121637	F	AD-0069	55	adult	-
UMAD-71.128607	F	AD-0071	49	adult	-
UMAD-72.121654	F	AD-0072	42	adult	-
UMAD-73.121313	F	AD-0073	40	adult	-
UMAD-74.121484	F	AD-0074	56	adult	Dup_of_CCF-0125
UMAD-75.121750	F	AD-0075	37	adult	-
UMAD-81.121449	F	AD-0081	53	adult	Dup_of_CCF-0314
UMAD-82.121779	F	AD-0082	32	adult	Dup_of_CCF-0089
UMAD-85.121254	F	AD-0085	50	adult	Daughter_of_AD-0151,Dup_of_CCF-0027
UMAD-86.121469	F	AD-0086	50	adult	relative_of_CCF.con-0306
UMAD-88.121252	F	AD-0088	50	adult	Dup_of_CCF-0118
UMAD-89.121357	F	AD-0089	46	adult	-
UMAD-94.121473	F	AD-0094	50	adult	Dup_of_CCF-0013
UMAD-99.121367	F	AD-0099	64	adult	Dup_of_CCF-0072
AD-0105.175574	F	AD-0105	58	adult	-
UMAD-108.121423	F	AD-0108	54	adult	-
AD-0109.175587	M	AD-0109	4	ped	Dup_of_AD-0109,Son_of_AD-0110,Son_of_AD-0111
UMAD-109.121390	M	AD-0109	4	ped	Dup_of_AD-0109,Son_of_AD-0110,Son_of_AD-0111
AD-0110.175570	F	AD-0110	38	ped_family	Mother_of_AD-0109
AD-0111.175551	M	AD-0111	38	ped_family	Father_of_AD-0109
AD-0112.175519	F	AD-0112	43	adult	-
AD-0113.175571	F	AD-0113	40	ped_family	Mother_of_AD-0115
AD-0114.175541	M	AD-0114	41	ped_family	Father_of_AD-0115
AD-0115.175566	M	AD-0115	5	ped	Dup_of_AD-0115,Son_of_AD-0113,Son_of_AD-0114
UMAD-115.121461	M	AD-0115	5	ped	Dup_of_AD-0115,Son_of_AD-0113,Son_of_AD-0114
UMAD-116.121331	F	AD-0116	49	adult	-
UMAD-117.121532	F	AD-0117	81	family	Mother_of_AD-0030,Mother_of_CCF-0015
UMAD-118.121763	F	AD-0118	50	adult	-
UMAD-119.121456	F	AD-0119	50	adult	-
UMAD-120.121394	F	AD-0120	55	adult	-
AD-0137.182231	M	AD-0137	51	adult	Dup_of_AD-0137,Mother_of_AD-0138,relative_of_AD-0166,Siblings_of_AD-0163
UMAD-137.121370	F	AD-0137	51	adult	Dup_of_AD-0137,Mother_of_AD-0138,relative_of_AD-0166,Siblings_of_AD-0163
AD-0138.175556	M	AD-0138	19	family	relative_of_AD-0163,relative_of_AD-0166,Son_of_AD-0137
UMAD-144.121282	F	AD-0144	52	adult	-
UMAD-151.121221	M	AD-0151	75	family	Father_of_AD-0085,Father_of_CCF-0027
UMAD-152.121851	F	AD-0152	53	adult	-
UMAD-156.121827	F	AD-0156	18	ped	-
UMAD-157.128512	F	AD-0157	21	adult	-
AD-0163.175522	F	AD-0163	50	adult	Dup_of_AD-0163,Mother_of_AD-0166,relative_of_AD-0138,Siblings_of_AD-0137
UMAD-163.121354	F	AD-0163	50	adult	Dup_of_AD-0163,Mother_of_AD-0166,relative_of_AD-0138,Siblings_of_AD-0137
AD0166.175863	F	AD-0166	21	adult	Daughter_of_AD-0163,relative_of_AD-0137,relative_of_AD-0138
UMAD-182.128663	F	AD-0182	38	adult	Daughter_of_AD-0183
UMAD-183.121455	F	AD-0183	82	family	Mother_of_AD-0182
UMAD-184.121766	F	AD-0184	54	adult	Daughter_of_AD-0185
UMAD-185.121729	F	AD-0185	87	family	Mother_of_AD-0184
UMAD-202.121584	F	AD-0202	66	adult	-
UMAD-212.121365	F	AD-0212	7	ped	-
UMAD-222.121301	F	AD-0222	75	adult	-
UMAD-225.121617	M	AD-0225	12	ped	-
AD-0228.175530	F	AD-0228	7	ped	-
UMAD-236.121680	M	AD-0236	8	ped	-
UMAD-244.121195	M	AD-0244	7	ped	-
UMAD-261.128530	F	AD-0261	63	adult	Dup_of_CCF-0375
UMAD-272.121658	M	AD-0272	15	ped	-
UMAD-273.121726	M	AD-0273	3	ped	-
AD-0283.175588	F	AD-0283	14	ped	Daughter_of_AD-0285,Daughter_of_AD-0286,Dup_of_AD-0283
UMAD-283.121406	F	AD-0283	14	ped	Daughter_of_AD-0285,Daughter_of_AD-0286,Dup_of_AD-0283
UMAD-284.121749	F	AD-0284	14	ped	-
AD-0285.175549	F	AD-0285	41	ped_family	Mother_of_AD-0283
AD-0286.175583	M	AD-0286	49	ped_family	Father_of_AD-0283
UMAD-292.121615	M	AD-0292	10	ped	-
AD-0295.175573	M	AD-0295	15	ped	Dup_of_AD-0295,Son_of_AD-0296,Son_of_AD-0297
UMAD-295.121728	M	AD-0295	15	ped	Dup_of_AD-0295,Son_of_AD-0296,Son_of_AD-0297
AD-0296.175568	F	AD-0296	50	ped_family	Mother_of_AD-0295
AD-0297.175580	M	AD-0297	49	ped_family	Father_of_AD-0295
UMAD-298.121736	M	AD-0298	8	ped	-
UMAD-302.121376	M	AD-0302	12	ped	-
AD-0309.175555	M	AD-0309	26	ped_family	Father_of_AD-0312
AD-0310.175561	F	AD-0310	26	ped_family	Mother_of_AD-0312
AD-0312.175539	M	AD-0312	1	ped	Dup_of_AD-0312,Son_of_AD-0309,Son_of_AD-0310
UMAD-312.121412	M	AD-0312	1	ped	Dup_of_AD-0312,Son_of_AD-0309,Son_of_AD-0310
UMAD-314.128672	M	AD-0314	60	adult	-
UMAD-317.128697	F	AD-0317	51	adult	-
AD-0320.175543	F	AD-0320	1	ped	Daughter_of_AD-0321,Daughter_of_AD-0323
AD-0321.175557	F	AD-0321	37	ped_family	Mother_of_AD-0320
AD-0322.175560	M	AD-0322	17	ped	Son_of_AD-0380,Son_of_AD-0381
AD-0323.175562	M	AD-0323	37	ped_family	Father_of_AD-0320
AD-0326.175531	F	AD-0326	14	ped	Daughter_of_AD-0327,Daughter_of_AD-0328
AD-0327.175548	M	AD-0327	42	ped_family	Father_of_AD-0326
AD-0328.175572	F	AD-0328	39	ped_family	Mother_of_AD-0326
AD-0332.175538	M	AD-0332	18	ped	-
AD-0333.175582	M	AD-0333	4	ped	-
AD-0334.175527	F	AD-0334	14	ped	-
AD-0335.175521	F	AD-0335	15	ped	-
AD-0338.175518	F	AD-0338	5	ped	-
AD-0339.175532	M	AD-0339	10	ped	-
AD-0353.175575	M	AD-0353	10	ped	-
AD-0366.175528	F	AD-0366	13	ped	-
AD-0370.175586	F	AD-0370	5	ped	-
AD-0374.175550	M	AD-0374	14	ped	Son_of_AD-0438,Son_of_AD-0439
AD-0375.175576	F	AD-0375	3	ped	-
AD-0380.175553	M	AD-0380	44	ped_family	Father_of_AD-0322
AD-0381.175525	F	AD-0381	46	ped_family	Mother_of_AD-0322
AD-0388.175534	M	AD-0388	46	ped_family	Father_of_AD-0049
AD-0395.175524	F	AD-0395	44	adult	-
AD-0396.175544	M	AD-0396	49	adult	-
AD-0402.175535	F	AD-0402	11	ped	-
AD-0413.175584	F	AD-0413	49	family	relative_of_AD-0431,Siblings_of_AD-0415,Siblings_of_AD-0417
AD-0415.175559	F	AD-0415	52	family	relative_of_AD-0431,Siblings_of_AD-0413,Siblings_of_AD-0417
AD-0416.175520	F	AD-0416	25	family	Siblings_of_AD-0420
AD-0417.175529	F	AD-0417	61	adult	relative_of_AD-0431,Siblings_of_AD-0413,Siblings_of_AD-0415
AD-0420.175546	F	AD-0420	29	family	Siblings_of_AD-0416
AD-0421.175540	M	AD-0421	7	ped	Son_of_AD-0422,Son_of_AD-0423
AD-0422.175517	F	AD-0422	33	ped_family	Mother_of_AD-0421
AD-0423.175536	M	AD-0423	38	ped_family	Father_of_AD-0421
AD-0424.175542	F	AD-0424	7	ped	Daughter_of_AD-0425,Daughter_of_AD-0426
AD-0425.175533	F	AD-0425	40	ped_family	Mother_of_AD-0424
AD-0426.175589	M	AD-0426	42	ped_family	Father_of_AD-0424
AD0431.175864	M	AD-0431	26	family	relative_of_AD-0413,relative_of_AD-0415,relative_of_AD-0417
AD-0432.175526	M	AD-0432	1	ped	Son_of_AD-0433,Son_of_AD-0434
AD-0433.175577	F	AD-0433	-	ped_family	Mother_of_AD-0432
AD-0434.175545	M	AD-0434	-	ped_family	Father_of_AD-0432
AD-0438.175523	M	AD-0438	40	ped_family	Mother_of_AD-0374
AD-0439.176083	F	AD-0439	40	ped_family	Father_of_AD-0374
AD-0443.175581	F	AD-0443	14	ped	Daughter_of_AD-0444,Daughter_of_AD-0445
AD-0444.175552	F	AD-0444	51	ped_family	Mother_of_AD-0443
AD-0445.175569	M	AD-0445	42	ped_family	Father_of_AD-0443
AD-0446.175558	M	AD-0446	2	ped	Son_of_AD-0447,Son_of_AD-0448
AD-0447.175564	M	AD-0447	31	ped_family	Father_of_AD-0446
AD-0448.175578	F	AD-0448	34	ped_family	Mother_of_AD-0446
CCF-2.121207	M	CCF-0002	59	adult	-
CCF-3.121535	F	CCF-0003	65	adult	-
CCF-6.121239	F	CCF-0006	41	adult	-
CCF-7.128976	F	CCF-0007	64	adult	Siblings_of_CCF-0011
CCF-8.121619	F	CCF-0008	60	adult	-
CCF-10.121229	F	CCF-0010	42	adult	-
CCF-11.121830	F	CCF-0011	72	adult	Siblings_of_CCF-0007
CCF-12.128668	F	CCF-0012	50	adult	Dup_of_AD-0046
CCF-13.121422	F	CCF-0013	51	adult	Dup_of_AD-0094
CCF-14.121391	F	CCF-0014	35	adult	-
CCF-15.121721	F	CCF-0015	55	adult	Daughter_of_AD-0117,Dup_of_AD-0030
CCF-17.128642	F	CCF-0017	41	adult	-
CCF-18.121833	F	CCF-0018	67	adult	-
CCF-20.121428	F	CCF-0020	53	adult	-
CCF-21.128694	F	CCF-0021	54	adult	-
CCF-23.128703	F	CCF-0023	47	adult	-
CCF-24.121248	F	CCF-0024	48	adult	-
CCF-25.121388	F	CCF-0025	34	adult	-
CCF-26.121264	F	CCF-0026	57	adult	-
CCF-27.121765	F	CCF-0027	47	adult	Daughter_of_AD-0151,Dup_of_AD-0085
CCF-28.128465	F	CCF-0028	70	adult	-
CCF-29.121371	F	CCF-0029	38	adult	-
CCF-30.121505	F	CCF-0030	57	adult	-
CCF-31.128701	F	CCF-0031	46	adult	-
CCF-32.121203	F	CCF-0032	41	adult	Mother_of_CCF-0305
CCF-33.121317	F	CCF-0033	43	adult	-
CCF-34.121361	F	CCF-0034	36	adult	-
CCF-35.128670	F	CCF-0035	38	adult	Dup_of_CCF-0143
CCF-38.121825	F	CCF-0038	36	adult	-
CCF-39.121545	F	CCF-0039	61	adult	-
CCF-40.121297	F	CCF-0040	45	adult	-
CCF-42.121233	F	CCF-0042	48	adult	-
CCF-43.121845	F	CCF-0043	23	adult	-
CCF-44.121581	F	CCF-0044	50	adult	-
CCF-45.121848	F	CCF-0045	64	adult	-
CCF-47.121431	F	CCF-0047	42	adult	-
CCF-48.121295	F	CCF-0048	51	adult	-
CCF-49.121196	F	CCF-0049	44	adult	-
CCF-58.121231	F	CCF-0058	66	adult	-
CCF-60.121538	F	CCF-0060	55	adult	-
CCF-61.121732	F	CCF-0061	45	adult	-
CCF-62.121700	F	CCF-0062	57	adult	-
CCF-64.121351	F	CCF-0064	67	adult	-
CCF-65.121675	M	CCF-0065	47	adult	-
CCF-67.121755	F	CCF-0067	40	adult	-
CCF-68.128682	F	CCF-0068	54	adult	-
CCF-69.121708	F	CCF-0069	56	adult	-
CCF-70.121344	M	CCF-0070	51	adult	-
CCF-72.121308	F	CCF-0072	65	adult	Dup_of_AD-0099
CCF-74.121640	F	CCF-0074	68	adult	-
CCF-75.121752	F	CCF-0075	48	adult	-
CCF-77.128594	F	CCF-0077	53	adult	-
CCF-81.121287	F	CCF-0081	54	adult	-
CCF-86.121470	F	CCF-0086	63	adult	-
CCF-87.121349	F	CCF-0087	51	adult	-
CCF-88.121260	F	CCF-0088	49	adult	-
CCF-89.121485	F	CCF-0089	32	adult	Dup_of_AD-0082
CCF-90.121498	F	CCF-0090	52	adult	-
CCF-91.128601	F	CCF-0091	52	adult	-
CCF-92.121540	F	CCF-0092	49	adult	-
CCF-96.128482	F	CCF-0096	59	adult	-
CCF-98.121657	M	CCF-0098	71	adult	-
CCF-99.121719	M	CCF-0099	42	adult	-
CCF-100.128968	F	CCF-0100	61	adult	-
CCF-103.121703	F	CCF-0103	42	adult	-
CCF-104.121571	F	CCF-0104	60	adult	-
CCF-110.121326	F	CCF-0110	44	adult	-
CCF-111.121314	F	CCF-0111	46	adult	-
CCF-112.121548	F	CCF-0112	44	adult	-
CCF-113.128741	F	CCF-0113	42	adult	-
CCF-114.128547	F	CCF-0114	40	adult	-
CCF-115.121795	F	CCF-0115	49	adult	-
CCF-117.128746	F	CCF-0117	65	adult	-
CCF-118.121564	F	CCF-0118	50	adult	Dup_of_AD-0088
CCF-121.121691	F	CCF-0121	69	adult	-
CCF-122.128619	F	CCF-0122	46	adult	Siblings_of_CCF-0381
CCF-123.121690	F	CCF-0123	54	adult	-
CCF-124.121754	F	CCF-0124	40	adult	-
CCF-125.121549	F	CCF-0125	56	adult	Dup_of_AD-0074
CCF-126.121774	F	CCF-0126	39	adult	Daughter_of_AD-0054,Dup_of_AD-0039,Siblings_of_CCF-0139
CCF-127.121820	F	CCF-0127	44	adult	-
CCF-128.121824	F	CCF-0128	41	adult	-
CCF-131.128611	F	CCF-0131	53	adult	-
CCF-132.121488	F	CCF-0132	69	adult	-
CCF-134.121737	F	CCF-0134	48	adult	-
CCF-135.128658	F	CCF-0135	45	adult	-
CCF-138.121813	F	CCF-0138	64	adult	-
CCF-139.121629	F	CCF-0139	41	adult	Daughter_of_AD-0054,Siblings_of_AD-0039,Siblings_of_CCF-0126
CCF-143.121604	F	CCF-0143	38	adult	Dup_of_CCF-0035
CCF-145.121800	M	CCF-0145	59	adult	-
CCF-146.121677	F	CCF-0146	46	adult	-
CCF-147.128492	F	CCF-0147	62	adult	-
CCF-151.121864	F	CCF-0151	18	adult	-
CCF-153.121414	F	CCF-0153	68	adult	-
CCF-160.128739	F	CCF-0160	62	adult	-
CCF-168.121274	M	CCF-0168	34	adult	-
CCF-172.121399	F	CCF-0172	35	adult	-
CCF-174.121283	F	CCF-0174	51	adult	Dup_of_CCF-0203
CCF-176.121228	F	CCF-0176	56	adult	-
CCF-179.121694	F	CCF-0179	42	adult	-
CCF-181.121377	F	CCF-0181	57	adult	-
CCF-182.128681	F	CCF-0182	58	adult	-
CCF-188.128534	F	CCF-0188	44	adult	-
CCF-189.121662	F	CCF-0189	57	adult	-
CCF-192.121681	F	CCF-0192	67	adult	-
CCF-194.121764	F	CCF-0194	42	adult	-
CCF-195.121606	F	CCF-0195	54	adult	-
CCF-199.128514	F	CCF-0199	38	adult	-
CCF-200.121247	F	CCF-0200	68	adult	-
CCF-202.121669	F	CCF-0202	48	adult	-
CCF-203.121714	F	CCF-0203	51	adult	Dup_of_CCF-0174
CCF-208.121822	F	CCF-0208	57	adult	-
CCF-211.121593	F	CCF-0211	47	adult	-
CCF-212.121291	F	CCF-0212	50	adult	-
CCF-213.121497	F	CCF-0213	59	adult	-
CCF-214.121193	F	CCF-0214	53	adult	-
CCF-215.121384	F	CCF-0215	50	adult	-
CCF-218.128575	F	CCF-0218	29	adult	-
CCF-221.121625	F	CCF-0221	46	adult	-
CCF-227.121802	F	CCF-0227	40	adult	-
CCF-229.121611	F	CCF-0229	44	adult	-
CCF-230.121501	F	CCF-0230	39	adult	-
CCF-232.121514	F	CCF-0232	47	adult	-
CCF-233.121576	F	CCF-0233	53	adult	-
CCF-234.121550	F	CCF-0234	45	adult	-
CCF-236.121261	F	CCF-0236	39	adult	-
CCF-237.121305	F	CCF-0237	46	adult	-
CCF-240.121446	F	CCF-0240	45	adult	-
CCF-241.128662	F	CCF-0241	47	adult	-
CCF-242.128699	F	CCF-0242	63	adult	-
CCF-244.121816	F	CCF-0244	38	adult	-
CCF-245.121232	F	CCF-0245	70	adult	-
CCF-246.121623	F	CCF-0246	40	adult	-
CCF-247.128499	F	CCF-0247	58	adult	-
CCF-248.121628	F	CCF-0248	40	adult	-
CCF-249.121369	F	CCF-0249	57	adult	-
CCF-250.128572	F	CCF-0250	30	adult	-
CCF-252.128652	F	CCF-0252	50	adult	-
CCF-253.128680	F	CCF-0253	61	adult	-
CCF-256.121645	F	CCF-0256	68	adult	-
CCF-263.121201	F	CCF-0263	57	adult	-
CCF-266.128732	F	CCF-0266	66	adult	-
CCF-267.121312	F	CCF-0267	43	adult	-
CCF-269.128542	F	CCF-0269	41	adult	-
CCF-270.121656	F	CCF-0270	64	adult	-
CCF-271.121482	F	CCF-0271	51	adult	-
CCF-272.121812	F	CCF-0272	70	adult	-
CCF-274.128557	F	CCF-0274	50	adult	-
CCF-278.121686	F	CCF-0278	67	adult	-
CCF-280.128478	F	CCF-0280	50	adult	-
CCF-283.121742	F	CCF-0283	61	adult	-
CCF-288.128723	F	CCF-0288	44	adult	-
CCF-289.121323	F	CCF-0289	34	adult	-
CCF-290.128497	F	CCF-0290	57	adult	-
CCF-291.121819	F	CCF-0291	47	adult	-
CCF-293.121614	F	CCF-0293	74	adult	-
CCF-294.128501	F	CCF-0294	53	adult	-
CCF-298.121475	F	CCF-0298	45	adult	-
CCF-299.121346	F	CCF-0299	51	adult	-
CCF-302.128609	F	CCF-0302	49	adult	-
CCF-303.128617	F	CCF-0303	62	adult	-
CCF-304.121224	F	CCF-0304	43	adult	-
CCF-305.121578	M	CCF-0305	28	family	Son_of_CCF-0032
CCF-307.121723	F	CCF-0307	69	adult	-
CCF-308.128569	F	CCF-0308	47	adult	-
CCF-309.121562	F	CCF-0309	71	adult	-
CCF-310.121664	F	CCF-0310	51	adult	-
CCF-311.121609	F	CCF-0311	48	adult	-
CCF-312.121761	F	CCF-0312	56	adult	-
CCF-313.121439	F	CCF-0313	32	adult	-
CCF-314.121678	F	CCF-0314	53	adult	Dup_of_AD-0081
CCF-315.121743	F	CCF-0315	57	adult	-
CCF-317.121647	F	CCF-0317	58	adult	-
CCF-318.121235	F	CCF-0318	64	adult	-
CCF-319.128574	F	CCF-0319	60	adult	-
CCF-320.121375	F	CCF-0320	55	adult	-
CCF-321.121783	F	CCF-0321	57	adult	-
CCF-323.128678	F	CCF-0323	49	adult	-
CCF-324.128500	F	CCF-0324	37	adult	-
CCF-325.121731	F	CCF-0325	46	adult	-
CCF-327.121636	F	CCF-0327	46	adult	-
CCF-329.121271	F	CCF-0329	45	adult	-
CCF-330.121809	F	CCF-0330	58	adult	-
CCF-331.121823	F	CCF-0331	32	adult	-
CCF-333.128502	F	CCF-0333	47	adult	-
CCF-334.121799	F	CCF-0334	54	adult	-
CCF-335.121211	F	CCF-0335	26	adult	-
CCF-336.121757	F	CCF-0336	49	adult	-
CCF-337.128463	F	CCF-0337	46	adult	-
CCF-338.121210	F	CCF-0338	48	adult	-
CCF-343.121541	F	CCF-0343	62	adult	-
CCF-344.121512	F	CCF-0344	47	adult	-
CCF-345.121214	F	CCF-0345	50	adult	-
CCF-346.121480	F	CCF-0346	52	adult	-
CCF-347.121338	F	CCF-0347	67	adult	-
CCF-348.121192	F	CCF-0348	41	adult	-
CCF-349.121739	F	CCF-0349	58	adult	-
CCF-350.121489	F	CCF-0350	47	adult	-
CCF-351.121717	F	CCF-0351	53	adult	-
CCF-355.121197	F	CCF-0355	20	adult	-
CCF-357.121544	F	CCF-0357	22	adult	-
CCF-361.121509	F	CCF-0361	40	adult	-
CCF-362.121652	F	CCF-0362	47	adult	-
CCF-364.128509	F	CCF-0364	38	adult	-
CCF-366.121583	F	CCF-0366	49	adult	-
CCF-367.121507	F	CCF-0367	48	adult	-
CCF-368.121419	F	CCF-0368	43	adult	-
CCF-372.121302	F	CCF-0372	56	adult	-
CCF-373.121198	F	CCF-0373	66	adult	-
CCF-374.121385	F	CCF-0374	43	adult	-
CCF-375.121688	F	CCF-0375	52	adult	Dup_of_AD-0261
CCF-376.128620	F	CCF-0376	64	adult	-
CCF-377.121465	F	CCF-0377	34	adult	-
CCF-381.121241	F	CCF-0381	53	adult	Siblings_of_CCF-0122
CCF-382.121626	F	CCF-0382	56	adult	-
CCF-383.121460	F	CCF-0383	60	adult	-
CCF-385.121704	F	CCF-0385	48	adult	-
CCF-386.121322	F	CCF-0386	49	adult	-
CCF-387.121426	F	CCF-0387	48	adult	-
CCF-388.121300	F	CCF-0388	58	adult	-
CCF-389.121258	F	CCF-0389	52	adult	-
CCF-390.128630	F	CCF-0390	40	adult	-
CCF-391.121237	F	CCF-0391	45	adult	-
CCF-392.121339	F	CCF-0392	51	adult	-
CCF-394.121402	F	CCF-0394	57	adult	-
CCF-395.128748	F	CCF-0395	57	adult	-
CCF-396.121272	F	CCF-0396	71	adult	-
CCF-397.121218	F	CCF-0397	63	adult	-
CCF-400.121355	F	CCF-0400	52	adult	-
CCF-401.121511	F	CCF-0401	56	adult	-
CCF-402.121534	F	CCF-0402	62	adult	-
CCF-403.121570	F	CCF-0403	45	adult	-
CCF-404.121597	F	CCF-0404	59	adult	-
CCF-406.121298	F	CCF-0406	72	adult	-
CCF-407.121289	F	CCF-0407	61	adult	-
CCF-408.121293	F	CCF-0408	28	adult	-
CCF-410.121551	F	CCF-0410	41	adult	-
CCF-412.121279	F	CCF-0412	63	adult	-
CCF.con-1.121568	F	CCF.con-0001	25	ctrl	-
CCF.con-2.121856	F	CCF.con-0002	26	ctrl	-
CCF.con-4.128737	F	CCF.con-0004	29	ctrl	-
CCF.con-6.121249	F	CCF.con-0006	32	ctrl	-
CCF.con-7.121223	F	CCF.con-0007	32	ctrl	-
CCF.con-8.128734	F	CCF.con-0008	32	ctrl	-
CCF.con-10.128692	F	CCF.con-0010	33	ctrl	-
CCF.con-11.121320	F	CCF.con-0011	33	ctrl	-
CCF.con-13.121421	F	CCF.con-0013	33	ctrl	-
CCF.con-14.121837	F	CCF.con-0014	34	ctrl	-
CCF.con-15.121474	F	CCF.con-0015	34	ctrl	-
CCF.con-16.121655	F	CCF.con-0016	34	ctrl	-
CCF.con-17.121850	F	CCF.con-0017	35	ctrl	-
CCF.con-18.121429	F	CCF.con-0018	35	ctrl	-
CCF.con-19.121543	F	CCF.con-0019	35	ctrl	-
CCF.con-20.128719	F	CCF.con-0020	35	ctrl	-
CCF.con-21.121337	F	CCF.con-0021	35	ctrl	-
CCF.con-28.128555	F	CCF.con-0028	38	ctrl	-
CCF.con-29.121452	F	CCF.con-0029	39	ctrl	-
CCF.con-33.121804	F	CCF.con-0033	40	ctrl	-
CCF.con-34.121348	F	CCF.con-0034	41	ctrl	-
CCF.con-36.121683	F	CCF.con-0036	41	ctrl	-
CCF.con-37.121663	F	CCF.con-0037	41	ctrl	-
CCF.con-38.121839	F	CCF.con-0038	41	ctrl	-
CCF.con-39.121340	F	CCF.con-0039	41	ctrl	-
CCF.con-40.121397	F	CCF.con-0040	41	ctrl	-
CCF.con-42.121638	F	CCF.con-0042	41	ctrl	-
CCF.con-43.121772	F	CCF.con-0043	42	ctrl	-
CCF.con-44.121230	F	CCF.con-0044	42	ctrl	-
CCF.con-45.128740	F	CCF.con-0045	42	ctrl	-
CCF.con-47.121722	F	CCF.con-0047	42	ctrl	-
CCF.con-48.128718	F	CCF.con-0048	42	ctrl	-
CCF.con-49.121327	F	CCF.con-0049	42	ctrl	-
CCF.con-50.121486	F	CCF.con-0050	43	ctrl	-
CCF.con-52.121718	F	CCF.con-0052	43	ctrl	-
CCF.con-53.121649	F	CCF.con-0053	43	ctrl	-
CCF.con-55.128712	F	CCF.con-0055	43	ctrl	-
CCF.con-58.121216	F	CCF.con-0058	43	ctrl	-
CCF.con-60.121782	F	CCF.con-0060	44	ctrl	-
CCF.con-62.121709	F	CCF.con-0062	44	ctrl	-
CCF.con-64.121510	F	CCF.con-0064	44	ctrl	-
CCF.con-65.121810	F	CCF.con-0065	44	ctrl	-
CCF.con-66.121400	F	CCF.con-0066	44	ctrl	-
CCF.con-68.121521	F	CCF.con-0068	44	ctrl	-
CCF.con-72.128533	F	CCF.con-0072	45	ctrl	-
CCF.con-73.128722	F	CCF.con-0073	45	ctrl	-
CCF.con-74.121220	F	CCF.con-0074	45	ctrl	-
CCF.con-75.128631	F	CCF.con-0075	45	ctrl	relative_of_CCF.con-0199
CCF.con-80.121582	F	CCF.con-0080	45	ctrl	-
CCF.con-81.121797	F	CCF.con-0081	46	ctrl	-
CCF.con-82.121336	F	CCF.con-0082	46	ctrl	-
CCF.con-84.121605	F	CCF.con-0084	46	ctrl	-
CCF.con-85.121711	F	CCF.con-0085	46	ctrl	-
CCF.con-87.121328	F	CCF.con-0087	46	ctrl	-
CCF.con-91.128532	F	CCF.con-0091	46	ctrl	-
CCF.con-92.128493	F	CCF.con-0092	46	ctrl	-
CCF.con-93.121487	F	CCF.con-0093	47	ctrl	-
CCF.con-94.128535	F	CCF.con-0094	47	ctrl	-
CCF.con-95.121608	F	CCF.con-0095	47	ctrl	-
CCF.con-98.121517	F	CCF.con-0098	47	ctrl	-
CCF.con-100.128661	F	CCF.con-0100	47	ctrl	-
CCF.con-101.121405	F	CCF.con-0101	48	ctrl	-
CCF.con-103.121244	F	CCF.con-0103	48	ctrl	-
CCF.con-104.121522	F	CCF.con-0104	48	ctrl	-
CCF.con-106.121205	F	CCF.con-0106	48	ctrl	-
CCF.con-107.121395	F	CCF.con-0107	48	ctrl	-
CCF.con-108.121250	F	CCF.con-0108	48	ctrl	-
CCF.con-109.121668	F	CCF.con-0109	48	ctrl	-
CCF.con-110.121266	F	CCF.con-0110	48	ctrl	-
CCF.con-112.121758	F	CCF.con-0112	48	ctrl	-
CCF.con-113.121515	F	CCF.con-0113	48	ctrl	-
CCF.con-115.128561	F	CCF.con-0115	48	ctrl	-
CCF.con-117.121519	F	CCF.con-0117	49	ctrl	-
CCF.con-120.121574	F	CCF.con-0120	49	ctrl	-
CCF.con-121.128714	F	CCF.con-0121	49	ctrl	-
CCF.con-124.128591	F	CCF.con-0124	49	ctrl	-
CCF.con-130.128691	F	CCF.con-0130	50	ctrl	-
CCF.con-132.121642	F	CCF.con-0132	50	ctrl	-
CCF.con-135.121444	F	CCF.con-0135	50	ctrl	-
CCF.con-136.121529	F	CCF.con-0136	50	ctrl	-
CCF.con-138.121660	F	CCF.con-0138	50	ctrl	-
CCF.con-141.121753	F	CCF.con-0141	50	ctrl	-
CCF.con-144.128622	F	CCF.con-0144	51	ctrl	-
CCF.con-145.128522	F	CCF.con-0145	51	ctrl	-
CCF.con-146.128633	F	CCF.con-0146	51	ctrl	-
CCF.con-148.121450	F	CCF.con-0148	51	ctrl	-
CCF.con-149.121624	F	CCF.con-0149	51	ctrl	-
CCF.con-152.128637	F	CCF.con-0152	51	ctrl	-
CCF.con-155.121667	F	CCF.con-0155	51	ctrl	-
CCF.con-157.121202	F	CCF.con-0157	51	ctrl	-
CCF.con-162.121410	F	CCF.con-0162	52	ctrl	-
CCF.con-167.121352	F	CCF.con-0167	52	ctrl	-
CCF.con-169.121673	F	CCF.con-0169	52	ctrl	-
CCF.con-170.121270	F	CCF.con-0170	52	ctrl	-
CCF.con-172.128639	F	CCF.con-0172	52	ctrl	-
CCF.con-175.121771	F	CCF.con-0175	53	ctrl	-
CCF.con-178.128488	F	CCF.con-0178	52	ctrl	-
CCF.con-180.121598	F	CCF.con-0180	53	ctrl	-
CCF.con-188.121710	F	CCF.con-0188	53	ctrl	-
CCF.con-190.121315	F	CCF.con-0190	53	ctrl	-
CCF.con-192.121472	F	CCF.con-0192	53	ctrl	-
CCF.con-194.121552	F	CCF.con-0194	54	ctrl	-
CCF.con-195.121528	F	CCF.con-0195	54	ctrl	-
CCF.con-197.121594	F	CCF.con-0197	54	ctrl	-
CCF.con-199.128966	F	CCF.con-0199	54	ctrl	relative_of_CCF.con-0075
CCF.con-200.121600	F	CCF.con-0200	53	ctrl	-
CCF.con-201.121303	F	CCF.con-0201	54	ctrl	-
CCF.con-205.128606	F	CCF.con-0205	54	ctrl	-
CCF.con-206.128649	F	CCF.con-0206	54	ctrl	-
CCF.con-207.121481	F	CCF.con-0207	54	ctrl	-
CCF.con-210.121567	F	CCF.con-0210	54	ctrl	-
CCF.con-213.121860	F	CCF.con-0213	54	ctrl	-
CCF.con-214.128539	F	CCF.con-0214	55	ctrl	-
CCF.con-219.121684	F	CCF.con-0219	55	ctrl	-
CCF.con-221.121441	F	CCF.con-0221	55	ctrl	-
CCF.con-224.121616	F	CCF.con-0224	55	ctrl	-
CCF.con-226.121213	F	CCF.con-0226	55	ctrl	-
CCF.con-228.121378	F	CCF.con-0228	55	ctrl	-
CCF.con-229.121648	F	CCF.con-0229	55	ctrl	-
CCF.con-230.121420	F	CCF.con-0230	55	ctrl	-
CCF.con-232.128696	F	CCF.con-0232	55	ctrl	-
CCF.con-235.128513	F	CCF.con-0235	55	ctrl	-
CCF.con-237.121832	F	CCF.con-0237	55	ctrl	-
CCF.con-238.121417	F	CCF.con-0238	55	ctrl	-
CCF.con-239.128526	F	CCF.con-0239	55	ctrl	-
CCF.con-240.128489	F	CCF.con-0240	55	ctrl	Siblings_of_CCF.con-0260
CCF.con-243.121814	F	CCF.con-0243	55	ctrl	-
CCF.con-245.128749	F	CCF.con-0245	55	ctrl	-
CCF.con-250.121727	F	CCF.con-0250	56	ctrl	-
CCF.con-252.121464	F	CCF.con-0252	56	ctrl	-
CCF.con-253.121345	F	CCF.con-0253	56	ctrl	-
CCF.con-259.121353	F	CCF.con-0259	56	ctrl	-
CCF.con-260.121381	F	CCF.con-0260	56	ctrl	Siblings_of_CCF.con-0240
CCF.con-261.121288	F	CCF.con-0261	56	ctrl	-
CCF.con-264.121321	F	CCF.con-0264	56	ctrl	-
CCF.con-265.128592	F	CCF.con-0265	56	ctrl	-
CCF.con-266.121500	F	CCF.con-0266	56	ctrl	-
CCF.con-270.121676	F	CCF.con-0270	56	ctrl	-
CCF.con-271.121362	F	CCF.con-0271	56	ctrl	-
CCF.con-275.121781	F	CCF.con-0275	57	ctrl	-
CCF.con-276.121748	F	CCF.con-0276	57	ctrl	-
CCF.con-278.121646	F	CCF.con-0278	57	ctrl	-
CCF.con-279.121746	F	CCF.con-0279	57	ctrl	-
CCF.con-283.121685	F	CCF.con-0283	57	ctrl	-
CCF.con-285.121368	F	CCF.con-0285	57	ctrl	-
CCF.con-287.121284	F	CCF.con-0287	57	ctrl	-
CCF.con-291.128977	F	CCF.con-0291	57	ctrl	-
CCF.con-292.121199	F	CCF.con-0292	57	ctrl	-
CCF.con-294.128602	F	CCF.con-0294	57	ctrl	-
CCF.con-297.128683	F	CCF.con-0297	57	ctrl	-
CCF.con-299.121398	F	CCF.con-0299	57	ctrl	-
CCF.con-300.121332	F	CCF.con-0300	58	ctrl	-
CCF.con-301.121644	F	CCF.con-0301	58	ctrl	-
CCF.con-304.121506	F	CCF.con-0304	58	ctrl	-
CCF.con-306.121859	F	CCF.con-0306	58	ctrl	relative_of_AD-0086
CCF.con-307.121740	F	CCF.con-0307	57	ctrl	-
CCF.con-309.121383	F	CCF.con-0309	58	ctrl	-
CCF.con-312.121744	F	CCF.con-0312	58	ctrl	-
CCF.con-315.121433	F	CCF.con-0315	58	ctrl	-
CCF.con-316.121580	F	CCF.con-0316	58	ctrl	-
CCF.con-321.128475	F	CCF.con-0321	58	ctrl	-
CCF.con-323.121715	F	CCF.con-0323	58	ctrl	-
CCF.con-324.121573	F	CCF.con-0324	58	ctrl	-
CCF.con-325.121633	F	CCF.con-0325	58	ctrl	-
CCF.con-327.121775	F	CCF.con-0327	58	ctrl	-
CCF.con-332.128677	F	CCF.con-0332	59	ctrl	-
CCF.con-334.121595	F	CCF.con-0334	59	ctrl	-
CCF.con-337.121227	F	CCF.con-0337	59	ctrl	-
CCF.con-340.121767	F	CCF.con-0340	59	ctrl	-
CCF.con-345.128553	F	CCF.con-0345	59	ctrl	-
CCF.con-348.121310	F	CCF.con-0348	59	ctrl	-
CCF.con-350.128711	F	CCF.con-0350	59	ctrl	-
CCF.con-353.128590	F	CCF.con-0353	60	ctrl	-
CCF.con-354.121525	F	CCF.con-0354	60	ctrl	-
CCF.con-356.128643	F	CCF.con-0356	60	ctrl	-
CCF.con-357.121701	F	CCF.con-0357	60	ctrl	-
CCF.con-358.121432	F	CCF.con-0358	60	ctrl	-
CCF.con-359.121793	F	CCF.con-0359	60	ctrl	-
CCF.con-360.128688	F	CCF.con-0360	60	ctrl	-
CCF.con-363.128470	F	CCF.con-0363	60	ctrl	-
CCF.con-364.121347	F	CCF.con-0364	60	ctrl	-
CCF.con-366.121234	F	CCF.con-0366	60	ctrl	-
CCF.con-367.121491	F	CCF.con-0367	60	ctrl	-
CCF.con-368.128608	F	CCF.con-0368	60	ctrl	-
CCF.con-369.121403	F	CCF.con-0369	60	ctrl	-
CCF.con-374.121318	F	CCF.con-0374	60	ctrl	-
CCF.con-377.121724	F	CCF.con-0377	61	ctrl	-
CCF.con-378.121546	F	CCF.con-0378	61	ctrl	-
CCF.con-379.121194	F	CCF.con-0379	61	ctrl	-
CCF.con-380.121503	F	CCF.con-0380	61	ctrl	-
CCF.con-381.121841	F	CCF.con-0381	61	ctrl	-
CCF.con-382.121539	F	CCF.con-0382	61	ctrl	-
CCF.con-386.121631	F	CCF.con-0386	61	ctrl	-
CCF.con-388.121834	F	CCF.con-0388	61	ctrl	-
CCF.con-390.121747	F	CCF.con-0390	61	ctrl	-
CCF.con-393.121585	F	CCF.con-0393	61	ctrl	-
CCF.con-394.121756	F	CCF.con-0394	61	ctrl	-
CCF.con-396.121494	F	CCF.con-0396	61	ctrl	-
CCF.con-397.121440	F	CCF.con-0397	61	ctrl	-
CCF.con-398.128587	F	CCF.con-0398	61	ctrl	-
CCF.con-399.128967	F	CCF.con-0399	61	ctrl	-
CCF.con-400.128487	F	CCF.con-0400	61	ctrl	-
CCF.con-401.121801	F	CCF.con-0401	61	ctrl	-
CCF.con-402.121358	F	CCF.con-0402	61	ctrl	-
CCF.con-403.128623	F	CCF.con-0403	61	ctrl	-
CCF.con-406.121447	F	CCF.con-0406	61	ctrl	-
CCF.con-408.128745	F	CCF.con-0408	62	ctrl	-
CCF.con-409.121760	F	CCF.con-0409	62	ctrl	-
CCF.con-410.121457	F	CCF.con-0410	62	ctrl	-
CCF.con-411.121789	F	CCF.con-0411	62	ctrl	-
CCF.con-414.121725	F	CCF.con-0414	62	ctrl	-
CCF.con-415.121513	F	CCF.con-0415	62	ctrl	-
CCF.con-416.121861	F	CCF.con-0416	62	ctrl	-
CCF.con-418.121666	F	CCF.con-0418	62	ctrl	-
CCF.con-419.128615	F	CCF.con-0419	63	ctrl	-
CCF.con-420.121671	F	CCF.con-0420	63	ctrl	-
CCF.con-421.121569	F	CCF.con-0421	63	ctrl	-
CCF.con-422.128464	F	CCF.con-0422	63	ctrl	-
CCF.con-424.128653	F	CCF.con-0424	63	ctrl	-
CCF.con-425.121670	F	CCF.con-0425	63	ctrl	-
CCF.con-426.121531	F	CCF.con-0426	63	ctrl	-
CCF.con-427.121411	F	CCF.con-0427	63	ctrl	-
CCF.con-429.121330	F	CCF.con-0429	63	ctrl	-
CCF.con-430.121360	F	CCF.con-0430	63	ctrl	-
CCF.con-431.121325	F	CCF.con-0431	64	ctrl	-
CCF.con-432.128519	F	CCF.con-0432	64	ctrl	-
CCF.con-434.121788	F	CCF.con-0434	64	ctrl	-
CCF.con-436.121692	F	CCF.con-0436	64	ctrl	-
CCF.con-437.121792	F	CCF.con-0437	64	ctrl	-
CCF.con-441.121689	F	CCF.con-0441	64	ctrl	-
CCF.con-443.128505	F	CCF.con-0443	64	ctrl	-
CCF.con-445.121219	F	CCF.con-0445	64	ctrl	-
CCF.con-447.121236	F	CCF.con-0447	64	ctrl	-
CCF.con-448.121862	F	CCF.con-0448	64	ctrl	-
CCF.con-449.121768	F	CCF.con-0449	65	ctrl	-
CCF.con-451.121707	F	CCF.con-0451	65	ctrl	-
CCF.con-452.121518	F	CCF.con-0452	65	ctrl	-
CCF.con-453.121208	F	CCF.con-0453	65	ctrl	-
CCF.con-456.121466	F	CCF.con-0456	65	ctrl	-
CCF.con-457.121382	F	CCF.con-0457	65	ctrl	-
CCF.con-458.128744	F	CCF.con-0458	65	ctrl	-
CCF.con-462.128636	F	CCF.con-0462	66	ctrl	-
CCF.con-463.121586	F	CCF.con-0463	66	ctrl	-
CCF.con-464.128462	F	CCF.con-0464	66	ctrl	-
CCF.con-466.128717	F	CCF.con-0466	66	ctrl	-
CCF.con-467.121716	F	CCF.con-0467	66	ctrl	-
CCF.con-469.121246	F	CCF.con-0469	67	ctrl	-
CCF.con-471.128614	F	CCF.con-0471	67	ctrl	-
CCF.con-472.121483	F	CCF.con-0472	67	ctrl	-
CCF.con-474.121276	F	CCF.con-0474	67	ctrl	-
CCF.con-478.121363	F	CCF.con-0478	68	ctrl	-
CCF.con-479.121222	F	CCF.con-0479	68	ctrl	-
CCF.con-481.121759	F	CCF.con-0481	68	ctrl	-
CCF.con-483.128545	F	CCF.con-0483	68	ctrl	-
CCF.con-486.121702	F	CCF.con-0486	69	ctrl	-
CCF.con-488.121643	F	CCF.con-0488	69	ctrl	-
CCF.con-489.121524	F	CCF.con-0489	69	ctrl	-
CCF.con-490.121285	F	CCF.con-0490	69	ctrl	-
CCF.con-491.121309	F	CCF.con-0491	70	ctrl	-
CCF.con-494.121695	F	CCF.con-0494	70	ctrl	-
CCF.con-495.121572	F	CCF.con-0495	70	ctrl	-
CCF.con-497.121805	F	CCF.con-0497	70	ctrl	-
CCF.con-499.121650	F	CCF.con-0499	70	ctrl	-
CCF.con-500.121496	F	CCF.con-0500	70	ctrl	-
CCF.con-502.128978	F	CCF.con-0502	70	ctrl	-
CCF.con-503.121387	F	CCF.con-0503	70	ctrl	-
CCF.con-505.121547	F	CCF.con-0505	71	ctrl	-
CCF.con-506.121516	F	CCF.con-0506	71	ctrl	-
CCF.con-509.128484	F	CCF.con-0509	71	ctrl	-
CCF.con-511.121831	F	CCF.con-0511	72	ctrl	-
CCF.con-513.121674	F	CCF.con-0513	72	ctrl	-
CCF.con-515.121334	F	CCF.con-0515	72	ctrl	-
CCF.con-516.121733	F	CCF.con-0516	72	ctrl	-
CCF.con-520.121296	F	CCF.con-0520	74	ctrl	-
CCF.con-521.121588	M	CCF.con-0521	25	ctrl	-
CCF.con-526.121751	M	CCF.con-0526	38	ctrl	-
CCF.con-527.128494	M	CCF.con-0527	37	ctrl	-
CCF.con-528.121251	M	CCF.con-0528	42	ctrl	-
CCF.con-529.121762	M	CCF.con-0529	42	ctrl	-
CCF.con-539.128537	M	CCF.con-0539	59	ctrl	-
CCF.con-540.121275	M	CCF.con-0540	59	ctrl	-
CCF.con-541.121821	M	CCF.con-0541	59	ctrl	-
CCF.con-542.121319	M	CCF.con-0542	59	ctrl	-
CCF.con-543.121665	M	CCF.con-0543	72	ctrl	-
