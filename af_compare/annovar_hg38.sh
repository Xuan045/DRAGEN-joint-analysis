#!/usr/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J annovar         # Job name
#SBATCH -p ngs186G           # Partition Name
#SBATCH -c 28               # core preserved
#SBATCH --mem=186G           # memory used
#SBATCH -o out.log          # Path to the standard output file
#SBATCH -e err.log          # Path to the standard error ouput file
#SBATCH --mail-user=
#SBATCH --mail-type=FAIL

###SBATCH --array=1-2

### Please define the following variables
config="/staging/biology/u4432941/dragen_accuracy/af_compare/ch_list"
INPUT="/staging/reserve/paylong_ntu/AI_SHARE/Pipeline/DRAGEN/TWB/TWB1492_dragenIGG_jointcalling.vcf.gz"
#para=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
para=merge
bed="/staging/reserve/paylong_ntu/AI_SHARE/Bed/WGS_interval/hg38/bed/${para}.bed"
wkdir="/staging/biology/u4432941/dragen_accuracy/af_compare"

### DO NOT CHANGE
BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
REF="/staging/reserve/paylong_ntu/AI_SHARE/reference/DRAGEN/v3.9.0/hs38DH/hs38DH.fa"
ANNOVAR="/opt/ohpc/Taiwania3/pkg/biology/ANNOVAR/annovar_20210819/table_annovar.pl"
humandb="/staging/reserve/paylong_ntu/AI_SHARE/reference/annovar_2016Feb01/humandb"


cd ${wkdir}
mkdir -p ${wkdir}
cd ${wkdir}
TIME=`date +%Y%m%d%H%M`
logfile=./${TIME}_${para}_run.log
exec >$logfile 2>&1
set -euo pipefail
set -x

#${BCFTOOLS} view -R ${bed} ${INPUT} -o ${para}.hg38.subset.vcf.gz
#${BCFTOOLS} norm -m- ${para}.hg38.subset.vcf.gz -O z -o ${wkdir}/${para}.hg38.decom.vcf.gz
#${BCFTOOLS} norm -f $REF ${wkdir}/${para}.hg38.decom.vcf.gz -O z -o ${wkdir}/${para}.hg38.decom.norm.vcf.gz

#perl ${ANNOVAR} ${wkdir}/${para}.hg38.decom.norm.vcf.gz $humandb -buildver hg38 -out ${para} -remove -protocol refGene,cytoBand,knownGene,ensGene,gnomad30_genome,avsnp150,TWB1492_AF,gnomad211_exome,clinvar_20210123,icgc28,dbnsfp41a -operation gx,r,gx,gx,f,f,f,f,f,f,f  -arg '-splicing 20',,,,,,,,,, -nastring . -vcfinput -polish

#rm ${para}.avinput ${para}.hg38.subset.vcf.gz ${para}.hg38.decom.vcf.gz

#bgzip chr1_1.hg38_multianno.vcf
#bgzip chr1_2.hg38_multianno.vcf

bcftools concat \
	--naive \
	-f file.list \
	-Ov -o chr1.hg38_multianno.vcf
