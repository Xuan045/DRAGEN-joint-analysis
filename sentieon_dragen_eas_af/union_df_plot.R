#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

# setwd("/Users/xuanchou/Documents/dragen_joint/sentieon_dragen_eas_af/")
# para <- "chr1_"

args <- commandArgs(trailingOnly = TRUE)
setwd(args[1])
para <- args[2]

union_df <- read.delim(paste0(para, "three_union.txt"), sep = "\t")

scatter_plot <- function(input_df, x_axis, y_axis) {
  # r^2: removing NA and using Pearson's correlation
  cor <- format(cor(as.numeric(input_df[[x_axis]]), as.numeric(input_df[[y_axis]]), 
                    method = "pearson", use = "complete.obs"), digits = 3)
  # Number of variants, add comma as a thousands separator
  var_count <- format(nrow(input_df[complete.cases(input_df[[x_axis]], input_df[[y_axis]]), ]), big.mark = ',')
  
  scatter_plot <- ggplot(data = input_df, aes(x = as.numeric(.data[[x_axis]]), y = as.numeric(.data[[y_axis]]))) +
    geom_point(color = "#909497") +
    geom_abline(slope = 1, linetype = "dashed") +
    theme_bw() +
    xlim(c(0, 1)) + ylim(c(0, 1)) +
    labs(x = x_axis, y = y_axis, 
         subtitle = bquote("Number of variants: " ~ .(var_count) ~ ", " ~ r^2 ~ "=" ~ .(cor)),
         caption = "Variants with AF > 0 in both datasets.") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          plot.caption = element_text(size = 10))
  return(scatter_plot)
}

# Plot dragen vs. eas
dragen_eas_df <- union_df[union_df$AF_eas > 0,]
dragen_eas_plt <- scatter_plot(dragen_eas_df, "AF_eas", "dragen_af") +
  labs(x = "gnomAD_eas AF", y = "DRAGEN_TWB1492 AF",
       title = "gnomAD_eas vs. DRAGEN")

## Save the plot as PNG using cairo device
png(paste0(para, "dragen_eas.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_eas_plt)

# Plot sentieon vs. eas
sentieon_eas_df <- union_df[union_df$AF_eas > 0,]
sentieon_eas_plt <- scatter_plot(sentieon_eas_df, "AF_eas", "sentieon_af") +
  labs(x = "gnomAD_eas AF", y = "Sentieon_TWB1492 AF",
       title = "gnomAD_eas vs. Sentieon")

## Save the plot as PNG using cairo device
png(paste0(para, "sentieon_eas.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_eas_plt)

# Plot sentieon vs. dragen
dragen_sentieon_plt <- scatter_plot(union_df, "dragen_af", "sentieon_af") +
  labs(x = "DRAGEN_TWB1492 AF", y = "Sentieon_TWB1492 AF",
       title = "DRAGEN vs. Sentieon")

## Save the plot as PNG using cairo device
png(paste0(para, "dragen_sentieon.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_sentieon_plt)
dev.off()

