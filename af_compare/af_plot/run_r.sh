#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J AF_R         # Job name
#SBATCH -p ngs186G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 28               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=186G           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o runR.out.log          # Path to the standard output file
#SBATCH -e runR.err.log          # Path to the standard error ouput file
#SBATCH --mail-user=judychou60@gmail.com
#SBATCH --mail-type=END              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL

module load pkg/R/4.1.2
module load compiler/gcc/9.4.0

/work/opt/ohpc/Taiwania3/pkg/biology/R/R_v4.1.0/bin/Rscript af_compare.R
