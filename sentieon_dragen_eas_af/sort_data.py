#!/usr/bin/env python

import argparse
import pandas as pd
import numpy as np


def clean_sentieon_df(sentieon_df):
    """
    Clean sentieon dataframes:
    1. Filter out variants that didn't pass the VQSR filter (SNP < 99.7, Indel < 99.5).
    2. Select columns to merge.
    """
    # Define filter_out values
    filter_out = ["VQSRTrancheINDEL99.90to100.00", "VQSRTrancheINDEL99.80to99.90", "VQSRTrancheINDEL99.70to99.80",
                  "VQSRTrancheINDEL99.60to99.70", "VQSRTrancheINDEL99.50to99.60", "VQSRTrancheSNP99.90to100.00",
                  "VQSRTrancheSNP99.80to99.90", "VQSRTrancheSNP99.70to99.80", "LowQual", "."]

    # Filter out rows based on filter_out values
    sentieon_df_vqsr = sentieon_df[~sentieon_df['TWB1492_QC'].isin(filter_out)]

    # Select columns
    selected_col = ["Chr", "Start", "End", "Ref", "Alt", "AF_eas", "TWB1492_AF"]
    sentieon_df_vqsr = sentieon_df_vqsr[selected_col]
    # Rename AF column
    sentieon_df_vqsr.rename(columns={'TWB1492_AF':'sentieon_af'}, inplace=True)

    return sentieon_df_vqsr

def clean_dragen_df(dragen_df):
    """
    Clean dragen dataframes:
    1. Select columns to merge.
    """
    # Select columns
    selected_col = ["Chr", "Start", "End", "Ref", "Alt", "AF_eas", "Otherinfo1"]
    dragen_df = dragen_df[selected_col]
    # Rename AF column
    dragen_df.rename(columns={'Otherinfo1':'dragen_af'}, inplace=True)
    
    return dragen_df

def main(output_dir, file_dir, para):
    # Load files
    sentieon_df = pd.read_csv(f"{file_dir}/sentieon_{para}.hg38_multianno.txt", sep="\t")
    dragen_df = pd.read_csv(f"{file_dir}/dragen_{para}.hg38_multianno.txt", sep="\t", usecols=range(0, dragen_df.columns.get_loc("Otherinfo1")+1))

    # Clean and filter dataframes
    sentieon_filtered_df = clean_sentieon_df(sentieon_df)
    print("finish sentieon cleaning ...")

    dragen_filtered_df = clean_dragen_df(dragen_df)
    print("finish dragen cleaning...")

    # Merge dataframes
    merged_df = dragen_filtered_df.merge(sentieon_filtered_df, on=['Chr', 'Start', 'End', 'Ref', 'Alt', 'AF_eas'])
    print("finish merging...")

    # Get union of three datasets
    union_df = pd.concat([merged_df, dragen_filtered_df, sentieon_filtered_df]).drop_duplicates(subset=['Chr', 'Start', 'End', 'Ref', 'Alt']).sort_values(by='Start')

    # Save output
    output_file = f"{output_dir}/{para}_three_union.txt"
    union_df.to_csv(output_file, sep='\t', index=False)
    print(f"Output saved to {output_file}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output_dir', required=True, help='Output directory')
    parser.add_argument('-f', '--file_dir', required=True, help='Input file directory')
    parser.add_argument('-p', '--para', required=True, help='Output parameter')
    args = parser.parse_args()

    main(args.output_dir, args.file_dir, args.para)
