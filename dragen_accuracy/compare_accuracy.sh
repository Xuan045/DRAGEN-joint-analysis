#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J HAPPY         # Job name
#SBATCH -p ngs92G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 14               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=92g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o happy.out.log          # Path to the standard output file
#SBATCH -e happy.err.log          # Path to the standard error ouput file
#SBATCH --mail-user=judychou60@gmail.com   
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

# Files need to provide
query_vcf="/staging/biology/u4432941/dragen_joint_calling/dragen_accuracy/HG002.norm.rmAD.vcf.gz"
para="HG002_gvcf_norm_confidence"

truth_vcf="/staging/reserve/paylong_ntu/AI_SHARE/reference/GIAB/AshkenazimTrio/HG002_NA24385_son/NISTv4.2.1/GRCh38/HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
ref="/work/opt/ohpc/Taiwania3/pkg/biology/IGG/IGG_software_build_v4.0.3_and_local_demo/ref/hg38.fa"
truth_bed="/staging/reserve/paylong_ntu/AI_SHARE/reference/GIAB/AshkenazimTrio/HG002_NA24385_son/NISTv4.2.1/GRCh38/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"

mkdir -p $para
cd $para

# Load Python2
module load biology/Python/2.7.18
export HGREF=$ref

set -euo pipefail

BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
happy=/opt/ohpc/Taiwania3/pkg/biology/illumina_hap.py/hap.py_v0.3.15

# Run hap.py
${happy}/bin/hap.py ${truth_vcf} ${query_vcf} \
	--filter-nonref \
	-f ${truth_bed} \
	-r ${ref} \
	-o ${para} \
	--logfile $(date +%Y%m%d%H%M)_${para}.log \
	--no-json \
	--leftshift \
	--bcftools-norm
