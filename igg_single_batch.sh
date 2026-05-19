#!/usr/bin/bash
#SBATCH -A MST109178
#SBATCH -J DRAGEN
#SBATCH -p ngs92G
#SBATCH -c 14
#SBATCH --mem=92g
#SBATCH -o dragen.out.log
#SBATCH -e dragen.err.log
#SBATCH --mail-user=
#SBATCH --mail-type=END

# Below parameters should be modified
# List of samples to perform gvcf-genotyper
sample_list="${PWD}/path_list/TWB1480_path.list"
output_dir="${PWD}/TWB1480_output_shards_vc_filter"

# Removes the <NON_REF> symbolic allele from the output of gVCF Genotyper.
gg_remove_nonref=true
# The gVCF Genotyper does not print variant alleles that are not called (hom-ref genotype) in any sample.
gg_discard_ac_zero=true
# Discard input variants that failed filters in the upstream caller.
gg_vc_filter=true

IGG_dir=/opt/ohpc/Taiwania3/pkg/biology/IGG/IGG_software_build_v4.0.3_and_local_demo/
dragen=$(realpath $IGG_dir/install/bin/dragen)
ref_fasta=$(realpath $IGG_dir/ref/hg38.fa)
config_dir=$IGG_dir/config
num_threads=48
num_shards=102
ulimit -n 71812
ulimit -u 16384

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
    --gg-discard-ac-zero $gg_discard_ac_zero \
    --gg-vc-filter $gg_vc_filter
