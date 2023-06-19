#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

setwd("/staging/biology/u4432941/dragen_joint_calling/af_compare/sentieon_dragen_eas_af")
dragen_df <- read_delim("/staging/biology/u4432941/dragen_joint_calling/af_compare/dragen_chr1.hg38_multianno.txt")
sentieon_df <- read_delim("/staging/biology/u4432941/dragen_joint_calling/af_compare/sentieon_chr1.hg38_multianno.txt")

# Scatter plot function
scatter_plot <- function(input_df, x_column, y_column){
  # Subset the data frame to non-NA values in both x-axis and y-axis columns
  non_na_df <- input_df[complete.cases(input_df[[x_column]], input_df[[y_column]]), ]
  
  # Get the count of non-NA data points
  data_points <- format(nrow(non_na_df), big.mark = ",")
  
  # r^2: removing NA and using Pearson's correlation
  cor <- format(cor(as.numeric(input_df[[x_column]]), as.numeric(input_df[[y_column]]),
                    method = "pearson", use = "complete.obs"), digits = 3)
  
  # Number of variants, add comma as a thousands separator
  var_count <- format(data_points, big.mark = ',')
  
  scatter_plot <- ggplot(data = input_df, aes(x = as.numeric(input_df[[x_column]]), y = as.numeric(input_df[[y_column]]))) +
    geom_point() +
    geom_abline(slope = 1, linetype = "dashed") +
    theme_bw() +
    xlim(c(0, 1)) + ylim(c(0, 1)) +
    labs(x = x_column, y = y_column,
    subtitle = bquote("Number of variants on chr1:" ~ .(var_count) ~ ", " ~ r^2 ~ "=" ~ .(cor)))
  return(scatter_plot)
}

# Sentieon
## Replace AF_eas "." with 0
sentieon_df$AF_eas...30 <- gsub("^\\.", 0, sentieon_df$AF_eas...30)

## Select VQSR pass (indel < 99.5, SNV < 99.7)
filter_out <- c("VQSRTrancheINDEL99.90to100.00", "VQSRTrancheINDEL99.80to99.90", "VQSRTrancheINDEL99.70to99.80",
                "VQSRTrancheINDEL99.60to99.70" , "VQSRTrancheINDEL99.50to99.60", "VQSRTrancheSNP99.90to100.00",
                "VQSRTrancheSNP99.80to99.90", "VQSRTrancheSNP99.70to99.80", "LowQual", ".")
sentieon_df_vqsr <- sentieon_df[!sentieon_df$TWB1492_QC %in% filter_out,]

sentieon_chr1_vqsr <- scatter_plot(sentieon_df_vqsr, "AF_eas...30", "TWB1492_AF") + 
  labs(x = "gnomAD_eas_AF", y = "Sentieon_TWB1492_AF", caption = "Select VQSR pass (indels < 99.5, SNVs < 99.7") +
  geom_point(color = "#CBBAED")
png("sentieon_chr1_vqsr_af.png", width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_chr1_vqsr)

sentieon_chr1 <- scatter_plot(sentieon_df, "AF_eas...30", "TWB1492_AF") +
  labs(x = "gnomAD_eas_AF", y = "Sentieon_TWB1492_AF") +
  geom_point(color = "#F1948A")
png("sentieon_chr1_af.png", width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_chr1)

# DRAGEN vs. gnomAD_EAS
## Replace AF_eas "." with 0
dragen_df$AF_eas...30 <- gsub("^\\.", 0, dragen_df$AF_eas...30)

dragen_chr1 <- scatter_plot(dragen_df, "AF_eas...30", "Otherinfo1") +
  labs(x = "gnomAD_eas_AF", y = "DRAGEN_TWB1492_AF") +
  geom_point(color = "#03C7BA")
png("dragen_chr1_af.png", width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_chr1)

## AF == 0 in gnomAD_eas, but with high AF in DRAGEN
weird_dragen <- dragen_df[(dragen_df$Otherinfo1 > 0.8) & (dragen_df$AF_eas...30 < 0.1),]
### Save the filtered data as a tab-delimited file
write.table(weird_dragen, file = "weird_af.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# DRAGEN vs. Sentieon
sentieon_vec <- with(sentieon_df, paste(Chr, Start, End, Ref, Alt))
dragen_vec <- with(dragen_df, paste(Chr, Start, End, Ref, Alt))
union_vec <- union(sentieon_vec, dragen_vec)

## 將結果轉換回資料框
union_df <- data.frame(matrix(unlist(strsplit(union_vec, " ")), ncol = 5, byrow = TRUE))
colnames(union_df) <- c("Chr", "Start", "End", "Ref", "Alt")

## Function: 把dataframe中的AF加入到union_df
add_af_to_union <- function(union_df, add_df, af_col_name, new_col_name) {
  # Create a new column in union_df to store sentieon_af
  union_df[[new_col_name]] <- NA
  
  # Compare ("Chr", "Start", "End", "Ref", "Alt") and fill in sentieon_af if a match is found
  for (i in 1:nrow(union_df)) {
    condition <- add_df$Chr == union_df$Chr[i] & 
      add_df$Start == union_df$Start[i] &
      add_df$End == union_df$End[i] &
      add_df$Ref == union_df$Ref[i] &
      add_df$Alt == union_df$Alt[i]
    
    matching_af <- add_df[[af_col_name]][condition]
    union_df[[new_col_name]][i] <- ifelse(length(matching_af) > 0, matching_af, 0)
  }
  
  return(union_df)
}


## 將sentieon_df中的TWB1492_AF資訊加入到union_df的sentieon_af欄位中
union_df <- add_af_to_union(union_df, sentieon_df, "TWB1492_AF", "sentieon_af")

## 將sentieon_df中的TWB1492_AF資訊加入到union_df的sentieon_af欄位中
union_df <- add_af_to_union(union_df, sentieon_df_vqsr, "TWB1492_AF", "sentieon_vqsr_af")
### 如果是因為VQSR沒過的話要改成NA
for (r in 1:nrow(union_df)) {
  if ((union_df[r, "sentieon_af"] != 0) & (union_df[r, "sentieon_vqsr_af"] == 0)) {
    union_df[r, "sentieon_vqsr_af"] <- NA
  }
}

## 將dragen_df中的Otherinfo1資訊加入到union_df的dragen_otherinfo1欄位中
union_df <- add_af_to_union(union_df, dragen_df, "Otherinfo1", "dragen_af")

write.table(union_df, file = "dragen_sentieon_union.txt", sep = "\t", row.names = FALSE)

sentieon_dragen_chr1_af <- scatter_plot(union_df, "sentieon_af", "dragen_af") +
  labs(x = "Sentieon_TWB1492_AF", y = "DRAGEN_TWB1492_AF") +
  geom_point(color = "#F8C471")
png("sentieon_dragen_chr1_af.png", width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_dragen_chr1_af)

sentieon_vqsr_dragen_chr1_af <- scatter_plot(union_df, "sentieon_vqsr_af", "dragen_af") +
  labs(x = "Sentieon_VQSR_TWB1492_AF", y = "DRAGEN_TWB1492_AF")+
  geom_point(color = "#F8C471")
png("sentieon_vqsr_dragen_chr1_af.png", width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_vqsr_dragen_chr1_af)

dev.off()