#!/bin/bash
sed 's/M-CAP/M_CAP/g' - | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AC\t%INFO/AF\t%INFO/AN\t%INFO/QD\t%INFO/Func.refGene\t%INFO/Gene.refGene\t%INFO/GeneDetail.refGene\t%INFO/ExonicFunc.refGene\t%INFO/AAChange.refGene\t%INFO/Func.ensGene\t%INFO/Gene.ensGene\t%INFO/GeneDetail.ensGene\t%INFO/ExonicFunc.ensGene\t%INFO/AAChange.ensGene\t%INFO/genomicSuperDups\t%INFO/PopFreqMax\t%INFO/1000G_ALL\t%INFO/ExAC_ALL\t%INFO/ESP6500siv2_ALL\t%INFO/gnomAD_exome_ALL\t%INFO/gnomAD_exome_NFE\t%INFO/gnomAD_genome_ALL\t%INFO/gnomAD_genome_NFE\t%INFO/InterVar_automated\t%INFO/CLNSIG\t%INFO/UMD_Score\t%INFO/UMD_Pred\t%INFO/CADD_raw\t%INFO/CADD_phred\t%INFO/SIFT_score\t%INFO/SIFT_pred\t%INFO/Polyphen2_HVAR_score\t%INFO/Polyphen2_HVAR_pred\t%INFO/CLNALLELEID\t%INFO/CLNDN\t%INFO/CLNDISDB\t%INFO/CLNREVSTAT\t%INFO/Interpro_domain\t%INFO/GTEx_V6p_gene\t%INFO/GTEx_V6p_tissue\t%INFO/snp129\t%INFO/avsnp150\t%INFO/cytoBand\t%INFO/PVS1\t%INFO/PS1\t%INFO/PS2\t%INFO/PS3\t%INFO/PS4\t%INFO/PM1\t%INFO/PM2\t%INFO/PM3\t%INFO/PM4\t%INFO/PM5\t%INFO/PM6\t%INFO/PP1\t%INFO/PP2\t%INFO/PP3\t%INFO/PP4\t%INFO/PP5\t%INFO/BA1\t%INFO/BS1\t%INFO/BS2\t%INFO/BS3\t%INFO/BS4\t%INFO/BP1\t%INFO/BP2\t%INFO/BP3\t%INFO/BP4\t%INFO/BP5\t%INFO/BP6\t%INFO/BP7\t%INFO/DP\t%INFO/FS\t%INFO/MQ\t-\t%INFO/MetaSVM_score\t%INFO/MetaSVM_pred\t%INFO/MetaLR_score\t%INFO/MetaLR_pred\t%INFO/M_CAP_score\t%INFO/M_CAP_pred\t%INFO/SIFT_score\t%INFO/SIFT_pred\t%INFO/Polyphen2_HDIV_score\t%INFO/Polyphen2_HDIV_pred\t%INFO/Polyphen2_HVAR_score\t%INFO/Polyphen2_HVAR_pred\t%INFO/LRT_score\t%INFO/LRT_pred\t%INFO/MutationTaster_score\t%INFO/MutationTaster_pred\t%INFO/MutationAssessor_score\t%INFO/MutationAssessor_pred\t%INFO/FATHMM_score\t%INFO/FATHMM_pred\t%INFO/PROVEAN_score\t%INFO/PROVEAN_pred\t%INFO/CADD_raw\t%INFO/CADD_phred\t%INFO/UMD_Score\t%INFO/UMD_Pred[\t%SAMPLE=%GT]\n' - | cat Annovar_Header -
