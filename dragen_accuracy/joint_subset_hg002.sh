#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J SUBSET_VCF         # Job name
#SBATCH -p ngs186G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 28               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=186g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o subset.out.log          # Path to the standard output file
#SBATCH -e subset.err.log          # Path to the standard error ouput file
#SBATCH --mail-user=judychou60@gmail.com   
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

vcf=/staging/reserve/paylong_ntu/AI_SHARE/Pipeline/DRAGEN/TWB/TWB1492_HG002_dragenIGG_hg38_joingcalling.vcf.gz
#vcf=/staging/reserve/paylong_ntu/AI_SHARE/Annotation/TWB_HQ164/HG002/HG002.novaseq.pcr-free_dragen_v4.0.3_hs38DH_graph.hard-filtered.vcf.gz
BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
REF=/staging/reserve/paylong_ntu/AI_SHARE/reference/DRAGEN/v3.9.0/hs38DH/hs38DH.fa

# Rename HG002.novaseq.pcr-free to HG002
#$BCFTOOLS reheader -s sample_name.txt $vcf | $BCFTOOLS view -s HG002 -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002.vcf.gz

# Split multiallelic sites
#$BCFTOOLS norm -f $REF -m- -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002_split.vcf.gz TWB1492_HG002_dragenIGG_joingcalling_HG002.vcf.gz

# AC > 0
#$BCFTOOLS view -c 1 -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002_split_AC1.vcf.gz TWB1492_HG002_dragenIGG_joingcalling_HG002_split.vcf.gz
#tabix -p vcf TWB1492_HG002_dragenIGG_joingcalling_HG002_split_AC1.vcf.gz
# Remove "AD" GT info
$BCFTOOLS annotate -x FORMAT/AD TWB1492_HG002_dragenIGG_joingcalling_HG002_split.vcf.gz -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002_split_rmAD.vcf.gz
#rm TWB1492_HG002_dragenIGG_joingcalling.vcf.gz
