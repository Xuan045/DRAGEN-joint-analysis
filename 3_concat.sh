#!/usr/bin/bash
#SBATCH -A MST109178
#SBATCH -J IGG_CONCAT
#SBATCH -p ngs92G
#SBATCH -c 14
#SBATCH --mem=92g
#SBATCH -o concat.out.log
#SBATCH -e concat.err.log
#SBATCH --mail-user=
#SBATCH --mail-type=END

# Output directory should be same with the pervious step
filedir="${PWD}/TWB1480_output_shards_vc_filter"
output_para="TWB1480_dragenIGG_jointcalling_vc_filter"

IGG_dir=/opt/ohpc/Taiwania3/pkg/biology/IGG/IGG_software_build_v4.0.3_and_local_demo/
dragen=$(realpath $IGG_dir/install/bin/dragen)
ref_fasta=$(realpath $IGG_dir/ref/hg38.fa)
config_dir=$IGG_dir/config
num_shards=102
ulimit -n 65535
ulimit -u 16384
module load biology
module load bcftools/1.13

for shard in $(seq 1 $num_shards); do
	realpath $filedir/shard-$shard/dragen.vcf.gz
done > concat.list

bcftools concat \
	--naive-force \
	--no-version \
	-Oz \
	-o $output_para.vcf.gz \
	-f concat.list
bcftools index -t -f $output_para.vcf.gz
