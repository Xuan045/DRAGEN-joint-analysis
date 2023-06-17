#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J DRAGEN         # Job name
#SBATCH -p ngs92G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 14               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=92g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o dragen.out.log          # Path to the standard output file
#SBATCH -e dragen.err.log          # Path to the standard error ouput file
#SBATCH --mail-user=
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

# Below parameters should be modified
# List of samples to perform gvcf-genotyper
sample_list=/staging/biology/u4432941/dragen_joint_calling/TWB1492_path.list
output_dir=TWB1492_output_shards
gg_remove_nonref=true
gg_discard_ac_zero=true

IGG_dir=/opt/ohpc/Taiwania3/pkg/biology/IGG/IGG_software_build_v4.0.3_and_local_demo/
dragen=$(realpath $IGG_dir/install/bin/dragen)
ref_fasta=$(realpath $IGG_dir/ref/hg38.fa)
config_dir=$IGG_dir/config
num_threads=48
num_shards=102
ulimit -n 71812
ulimit -u 16384
module load biology/bcftools/1.13
mkdir -p $output_dir

shard=$1
shard_dir=$output_dir/shard-$shard
rm -rf $shard_dir
mkdir -p $shard_dir

$dragen \
    --sw-mode \
    --enable-gvcf-genotyper-iterative true \
    --variant-list $sample_list \
    --shard $shard/$num_shards \
    --num-threads $num_threads \
    --logging-to-output-dir true \
    --output-directory $shard_dir \
    --ht-reference $ref_fasta \
    --gg-remove-nonref $gg_remove_nonref \
    --gg-discard-ac-zero $gg_discard_ac_zero
