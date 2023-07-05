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
    # Convert Start, End, AF_eas, dragen_af to numeric
    numeric_col = ["Start", "End", "AF_eas", "sentieon_af"]
    sentieon_df_vqsr[numeric_col] = sentieon_df_vqsr[numeric_col].apply(pd.to_numeric, errors='coerce')

    # Replace '.' with NaN in sentieon_filtered_df
    sentieon_df_vqsr = sentieon_df_vqsr.replace('.', np.nan)

    return sentieon_df_vqsr

def clean_dragen_df(dragen_df):
    """
    Clean dragen dataframes:
    Select columns to merge.
    """
    # Select columns
    selected_col = ["Chr", "Start", "End", "Ref", "Alt", "AF_eas", "Otherinfo1"]
    dragen_df = dragen_df[selected_col]
    # Rename AF column
    dragen_df.rename(columns={'Otherinfo1':'dragen_af'}, inplace=True)
    # Convert Start, End, AF_eas, dragen_af to numeric
    numeric_col = ["Start", "End", "AF_eas", "dragen_af"]
    dragen_df[numeric_col] = dragen_df[numeric_col].apply(pd.to_numeric, errors='coerce')
    
    # Replace '.' with NaN in sentieon_filtered_df
    dragen_df = dragen_df.replace('.', np.nan) 
    
    return dragen_df

def main(output_dir, dragen_file, sentieon_file, para):
    # Load files
    col_id = list(range(0, 5)) + list (range(21, 37))
    sentieon_df = pd.read_csv(sentieon_file, sep="\t", usecols=col_id)
    col_id = list(range(0, 5)) + list (range(21, 37)) + [112]
    dragen_df = pd.read_csv(dragen_file, sep="\t", usecols=col_id)

    # Clean and filter dataframes
    sentieon_filtered_df = clean_sentieon_df(sentieon_df)
    print("finish sentieon cleaning ...")
    sentieon_filtered_df.to_csv(f"{output_dir}/{para}_sentieon.txt", sep='\t', index=False)
    
    dragen_filtered_df = clean_dragen_df(dragen_df)
    print("finish dragen cleaning...")
    dragen_filtered_df.to_csv(f"{output_dir}/{para}_dragen.txt", sep='\t', index=False)

    # Get union of three datasets
    union_df = pd.merge(sentieon_filtered_df, dragen_filtered_df, on=['Chr', 'Start', 'End', 'Ref', 'Alt', 'AF_eas'], how='outer').sort_values('Start', ignore_index=True)

    # Save output
    output_file = f"{output_dir}/{para}_three_union.txt"
    union_df.to_csv(output_file, sep='\t', index=False)
    print(f"Output saved to {output_file}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output-dir', required=True, help='Output directory')
    parser.add_argument('-d', '--dragen-file', required=True, help='DRAGEN file path')
    parser.add_argument('-s', '--sentieon-file', required=True, help='Sentieon file path')
    parser.add_argument('-p', '--para', required=True, help='Output parameter')
    args = parser.parse_args()

    main(args.output_dir, args.dragen_file, args.sentieon_file, args.para)
