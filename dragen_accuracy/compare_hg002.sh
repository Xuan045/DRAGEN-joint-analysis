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

gg_vcf=/staging/biology/u4432941/dragen_joint_calling/dragen_accuracy/TWB1492_HG002_dragenIGG_joingcalling_HG002_split_AC1.vcf.gz
single_vcf=/staging/biology/u4432941/dragen_joint_calling/dragen_accuracy/HG002.norm.vcf
BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
outdir=/staging/biology/u4432941/dragen_joint_calling/dragen_accuracy/compare_hg002
mkdir -p $outdir

$BCFTOOLS isec -p $outdir $gg_vcf $single_vcf
