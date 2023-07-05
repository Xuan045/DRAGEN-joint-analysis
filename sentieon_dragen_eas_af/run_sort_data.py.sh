#!/usr/bin/sh
#SBATCH -A MST109178        
#SBATCH -J SortPy         
#SBATCH -p ngs186G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 28               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=186G           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o out.log          # Path to the standard output file
#SBATCH -e err.log          # Path to the standard error ouput file
#SBATCH --mail-user=judychou60@gmail.com
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

para="sortPy"
outdir="/staging/biology/u4432941/dragen_joint_calling/sentieon_dragen_eas_af"
dragen="/staging/biology/u4432941/dragen_joint_calling/annovar_annotation/dragen_chr1.hg38_multianno.txt"
sentieon="/staging/biology/u4432941/dragen_joint_calling/annovar_annotation/sentieon_chr1.hg38_multianno.txt"
sort_py="/staging/biology/u4432941/dragen_joint_calling/sentieon_dragen_eas_af/sort_data.py"
plot_r="/staging/biology/u4432941/dragen_joint_calling/sentieon_dragen_eas_af/union_df_plot.R"

set -euo pipefail
module load pkg/Anaconda3
module load pkg/R/4.1.2
module load compiler/gcc/9.4.0

# Log file settings
TIME=`date +%Y%m%d%H%M`
logfile=./${TIME}_run_${para}.log

# Redirect standard output and error to the log file
exec > "$logfile" 2>&1

#python $sort_py -o $outdir -s $sentieon -d $dragen -p chr1
/work/opt/ohpc/Taiwania3/pkg/biology/R/R_v4.1.0/bin/Rscript $plot_r $outdir chr1_
