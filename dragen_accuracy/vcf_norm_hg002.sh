#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J SUBSET_gVCF         # Job name
#SBATCH -p ngs92G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 14               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=92g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o subset.out.log          # Path to the standard output file
#SBATCH -e subset.err.log          # Path to the standard error ouput file
#SBATCH --mail-user=judychou60@gmail.com   
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

vcf=/staging/reserve/paylong_ntu/AI_SHARE/Annotation/TWB_HQ164/HG002/HG002.novaseq.pcr-free_dragen_v4.0.3_hs38DH_graph.hard-filtered.vcf.gz
BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
REF=/staging/reserve/paylong_ntu/AI_SHARE/reference/DRAGEN/v3.9.0/hs38DH/hs38DH.fa
para=HG002

# Split multiallelic sites and left-align
$BCFTOOLS norm -f $REF -m- -Oz -o ${para}.norm.vcf.gz $vcf
$BCFTOOLS annotate -x FORMAT/AD -Oz -o ${para}.norm.rmAD.vcf.gz ${para}.norm.vcf.gz
tabix ${para}.norm.rmAD.vcf.gz
