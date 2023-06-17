#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)
library(Cairo)

setwd("/staging/biology/u4432941/dragen_accuracy/af_compare/af_plot")
file <- "/staging/biology/u4432941/dragen_accuracy/af_compare/chr1.hg38_multianno.txt"

df <- read.delim(file, sep = '\t')

# Scatter plot function
scatter_plot <- function(input_df){
  # r^2: removing NA and using Pearson's correlation
  cor <- format(cor(as.numeric(input_df$AF_eas), as.numeric(input_df$Otherinfo1), 
                    method = "pearson", use = "complete.obs"), digits = 3)
  # Number of variants
  var_count <- nrow(input_df[input_df$Otherinfo1 != 0,])
  
  scatter_plot <- ggplot(data = input_df, aes(x = as.numeric(AF_eas), y = as.numeric(Otherinfo1))) +
    geom_point() +
    geom_abline(slope = 1, linetype = "dashed") +
    theme_bw() +
    xlim(c(0, 1)) + ylim(c(0, 1)) +
    labs(x = "gnomAD_eas", y = "TWB1492_DRAGEN", 
         subtitle = paste("Number of variants:", var_count, "\nr^2 =", cor))
  return(scatter_plot)
}

af_plot <- scatter_plot(df)

# Save the plot as PNG using cairo_png device
png("chr1_af.png", width = 6, height = 5, units = "in", res = 500, type = "cairo")
print(af_plot)
dev.off()
