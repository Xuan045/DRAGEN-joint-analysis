#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

setwd("/staging/biology/u4432941/dragen_joint_calling/sentieon_dragen_eas_af/3conf/")
union_df <- read.delim("chr1_three_union.txt", header = TRUE)
para <- "chr1_"

# replace "." with NA in the AF_eas column 
union_df$AF_eas[union_df$AF_eas == "."] <- NA

# add a new column "low_sention"
# if snetieon_af - gnomad_eas_af > 0.1, then add TRUE to low_sentieon
union_df$low_sentieon <- as.numeric(union_df$AF_eas) - as.numeric(union_df$sentieon_af) > 0.1

scatter_plot <- function(input_df, x_axis, y_axis) {
  # r^2: removing NA and using Pearson's correlation
  cor <- format(cor(as.numeric(input_df[[x_axis]]), as.numeric(input_df[[y_axis]]), 
                    method = "pearson", use = "complete.obs"), digits = 3)
  # Number of variants, add comma as a thousands separator
  var_count <- format(nrow(input_df[!is.na(input_df[[x_axis]]) & !is.na(input_df[[y_axis]]), ]), big.mark = ',')
  
  scatter_plot <- ggplot(data = input_df, aes(x = as.numeric(.data[[x_axis]]), y = as.numeric(.data[[y_axis]]))) +
    geom_point(aes(color = low_sentieon), size = 3) +
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

sentieon_eas_plt <- scatter_plot(union_df[union_df$AF_eas > 0,], "AF_eas", "sentieon_af") +
  labs(x = "gnomAD_eas AF", y = "Sentieon_TWB1492 AF",
       title = "gnomAD_eas vs. Sentieon")
sentieon_eas_plt <- sentieon_eas_plt + scale_color_manual(values = c("TRUE" = "#E74C3C", "FALSE" = "#909497"))
png(paste0(para, "sentieon_eas_colored.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_eas_plt)

dragen_eas_plt <- scatter_plot(union_df[union_df$AF_eas > 0,], "AF_eas", "dragen_af") +
  labs(x = "gnomAD_eas AF", y = "DRAGEN_TWB1492 AF",
       title = "gnomAD_eas vs. DRAGEN")
dragen_eas_plt <- dragen_eas_plt + scale_color_manual(values = c("TRUE" = "#E74C3C", "FALSE" = "#909497"))
png(paste0(para, "dragen_eas_colored.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_eas_plt)
  
