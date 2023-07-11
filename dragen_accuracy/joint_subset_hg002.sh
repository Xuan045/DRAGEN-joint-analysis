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
BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
REF=/staging/reserve/paylong_ntu/AI_SHARE/reference/DRAGEN/v3.9.0/hs38DH/hs38DH.fa

$BCFTOOLS view -s HG002.novaseq.pcr-free -i 'GT="alt"' -c1 -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002.vcf.gz

# Split multiallelic sites
$BCFTOOLS norm -f $REF -m- -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002_split.vcf.gz TWB1492_HG002_dragenIGG_joingcalling_HG002.vcf.gz

# Remove "AD" GT info
$BCFTOOLS annotate -x FORMAT/AD TWB1492_HG002_dragenIGG_joingcalling_HG002_split.vcf.gz -Oz -o TWB1492_HG002_dragenIGG_joingcalling_HG002_rmAD.vcf.gz
tabix TWB1492_HG002_dragenIGG_joingcalling_HG002_rmAD.vcf.gz
