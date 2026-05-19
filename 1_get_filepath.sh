#!/usr/bin/bash

# # Files excluding high-quality samples
# file=/staging/biology/u4432941/dragen_joint_calling/file.list
# file_dir=/staging/reserve/paylong_ntu/AI_SHARE/Pipeline/DRAGEN/TWB
# path_file=/staging/biology/u4432941/dragen_joint_calling/path.list

# rm -rf $path_file
# touch $path_file

# while read -r ID;
# 	do
# 	cd $file_dir/$ID
# 	realpath *.gvcf.gz >> $path_file
# 	done<$file

# # Files of high-quality samples and HG002
# hq_path_list="/staging/biology/u4432941/dragen_joint_calling/hq164_hg002_path.list"

# cat $path_file $hq_path_list > TWB1492_HG002_path.list
# grep -v 'HG002' TWB1492_HG002_path.list > TWB1492_path.list
# grep -v 'NGS1_20170107F\|NGS1_20170110A' TWB1492_HG002_path.list > TWB1490_HG002_path.list

# Gether TWB1480 file list
twb1480_list="/staging/reserve/jacobhsu/TWB/TWB_1490/TWB1480_sample.txt"
output_list="${PWD}/path_list/TWB1480_path.list"

> "$output_list"  # Clear the file first

while read -r ID; do
    dragen_path="/staging/reserve/paylong_ntu/AI_SHARE/Pipeline/DRAGEN/TWB/$ID"
    annotation_path="/staging/reserve/paylong_ntu/AI_SHARE/Annotation/TWB_HQ164/$ID"

    if [ -d "$dragen_path" ] && compgen -G "$dragen_path/*.gvcf.gz" > /dev/null; then
        realpath "$dragen_path"/*.gvcf.gz >> "$output_list"
    elif [ -d "$annotation_path" ] && compgen -G "$annotation_path/*.gvcf.gz" > /dev/null; then
        realpath "$annotation_path"/*.gvcf.gz >> "$output_list"
    else
        echo "Warning: .gvcf.gz not found for $ID" >&2
    fi
done < "$twb1480_list"
