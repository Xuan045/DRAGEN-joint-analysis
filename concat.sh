#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J DRAGEN         # Job name
#SBATCH -p ngs92G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 14               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=92g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o concat.out.log          # Path to the standard output file
#SBATCH -e concat.err.log          # Path to the standard error ouput file
#SBATCH --mail-user=
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

# Output directory should be same with the pervious step
output_dir=TWB1492_output_shards
output_para=TWB1492_dragenIGG_jointcalling

IGG_dir=/opt/ohpc/Taiwania3/pkg/biology/IGG/IGG_software_build_v4.0.3_and_local_demo/
dragen=$(realpath $IGG_dir/install/bin/dragen)
ref_fasta=$(realpath $IGG_dir/ref/hg38.fa)
config_dir=$IGG_dir/config
num_shards=102
ulimit -n 65535
ulimit -u 16384
module load biology/bcftools/1.13

for shard in $(seq 1 $num_shards); do
	realpath $output_dir/shard-$shard/dragen.vcf.gz
done > concat.list

bcftools concat \
	--naive-force \
	--no-version \
	-Oz \
	-o $output_para.vcf.gz \
	-f concat.list
bcftools index -t -f $output_para.vcf.gz
