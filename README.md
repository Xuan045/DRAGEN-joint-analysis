# DRAGEN-joint-calling

1. `1_get_filepath.sh`

    This script collects paths to sample data files and generates list, including:

    a. TWB1492_path.list: List of sample paths for TWB1492.
    
    b. TWB1492_HG002_path.list: List of sample paths for TWB1492 with HG002 data.
    
    c. TWB1490_HG002_path.list: Initially included samples for TWB1490 with HG002 data. Two samples (NGS1_20170107F and NGS1_20170110A) have been removed due to close relatedness.

2. `2_run_igg_single_batch.sh`

    This script executes joint anlaysis by DRAGEN IGG. It divides the whole genome into 102 shards. For the corresponding position in each shard (hg38), refer to the file: `/work/opt/ohpc/Taiwania3/pkg/biology/IGG/IGG_software_build_v4.0.3_and_local_demo/config/shards.hg38.3366.102.1.1.txt`.

    Note: Running all 102 shards simultaneously is not recommended in Taiwania3, especially for large sample sets.

3. `3_concat.sh`
    
    This script uses BCFTOOLS to concatenate the files generated in step 2. Make sure to load the required module beforehand.