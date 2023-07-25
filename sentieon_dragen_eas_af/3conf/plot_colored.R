#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)

# setwd("/Users/xuanchou/Documents/dragen_joint/sentieon_dragen_eas_af/3conf/")
setwd("/staging/biology/u4432941/dragen_joint_calling/sentieon_dragen_eas_af/3conf/")
union_df <- read.delim("chr1_three_union.txt", header = TRUE)
para <- "chr1_"

# replace "." with NA in the AF_eas column 
union_df$AF_eas[union_df$AF_eas == "."] <- NA

scatter_plot <- function(input_df, x_axis, y_axis, color_col, color) {
  # r^2: removing NA and using Pearson's correlation
  cor <- format(cor(as.numeric(input_df[[x_axis]]), as.numeric(input_df[[y_axis]]), 
                    method = "pearson", use = "complete.obs"), digits = 3)
  # Number of variants, add comma as a thousands separator
  var_count <- format(nrow(input_df[!is.na(input_df[[x_axis]]) & !is.na(input_df[[y_axis]]), ]), big.mark = ',')
  
  scatter_plot <- ggplot(data = input_df, aes(x = as.numeric(.data[[x_axis]]), y = as.numeric(.data[[y_axis]]))) +
    geom_point(aes(color = input_df[[color_col]]), size = 3) +
    geom_abline(slope = 1, linetype = "dashed") +
    theme_bw() +
    xlim(c(0, 1)) + ylim(c(0, 1)) +
    labs(x = x_axis, y = y_axis, 
         subtitle = bquote("Number of variants: " ~ .(var_count) ~ ", " ~ r^2 ~ "=" ~ .(cor)),
         caption = "Variants with AF > 0 in both datasets.") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          plot.caption = element_text(size = 10)) +
    scale_color_manual(color_col, values = c("TRUE" = color, "FALSE" = "#909497"))
  return(scatter_plot)
}

####################################################
# variants with high af in eas, low in sentieon
# label these variants as red
####################################################

# add a new column "low_sention"
# if gnomad_eas_af - sentieon_af > 0.1, then add TRUE to low_sentieon
union_df$low_sentieon <- as.numeric(union_df$AF_eas) - as.numeric(union_df$sentieon_af) > 0.1

sentieon_eas_plt <- scatter_plot(union_df[union_df$AF_eas > 0,], "AF_eas", "sentieon_af", "low_sentieon", "#F8C471") +
  labs(x = "gnomAD_eas AF", y = "Sentieon_TWB1492 AF",
       title = "gnomAD_eas vs. Sentieon")
png(paste0(para, "sentieon_eas_colored.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_eas_plt)

dragen_eas_plt <- scatter_plot(union_df[(union_df$AF_eas > 0),], "AF_eas", "dragen_af", "low_sentieon", "#F8C471") +
  labs(x = "gnomAD_eas AF", y = "DRAGEN_TWB1492 AF",
       title = "gnomAD_eas vs. DRAGEN")
png(paste0(para, "dragen_eas_colored.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_eas_plt)

# Make a plot that only show colored dots
dragen_eas_color_only_plt <- scatter_plot(union_df[(union_df$AF_eas > 0) & (union_df$low_sentieon == TRUE),], 
                                          "AF_eas", "dragen_af", "low_sentieon", "#F8C471") +
  labs(x = "gnomAD_eas AF", y = "DRAGEN_TWB1492 AF",
       title = "gnomAD_eas vs. DRAGEN") +
  theme(plot.subtitle = element_blank())
png(paste0(para, "dragen_eas_colored_only.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_eas_color_only_plt)

####################################################
# variants with high af in dragen, low in eas
# label these variants as blue
####################################################
# add a new column "high_dragen"
# if dragen_af - gnomad_eas_af > 0.1, then add TRUE to low_sentieon
union_df$high_dragen <- as.numeric(union_df$dragen_af) - as.numeric(union_df$AF_eas) > 0.1

dragen_eas_2_plt <- scatter_plot(union_df[(union_df$AF_eas > 0),], "AF_eas", "dragen_af", "high_dragen", "#7FB3D5") +
  labs(x = "gnomAD_eas AF", y = "DRAGEN_TWB1492 AF",
       title = "gnomAD_eas vs. DRAGEN")
png(paste0(para, "dragen_eas_colored_2.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_eas_2_plt)

sentieon_eas_2_plt <- scatter_plot(union_df[union_df$AF_eas > 0,], "AF_eas", "sentieon_af", "high_dragen", "#7FB3D5") +
  labs(x = "gnomAD_eas AF", y = "Sentieon_TWB1492 AF",
       title = "gnomAD_eas vs. Sentieon")
png(paste0(para, "sentieon_eas_colored_2.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(sentieon_eas_2_plt)

# Make a plot that only show colored dots
sentieon_eas_color_only_plt <- scatter_plot(union_df[(union_df$AF_eas > 0) & (union_df$high_dragen == TRUE),], 
                                          "AF_eas", "sentieon_af", "high_dragen", "#7FB3D5") +
  labs(x = "gnomAD_eas AF", y = "Sentieon_TWB1492 AF",
       title = "gnomAD_eas vs. Sentieon") +
  theme(plot.subtitle = element_blank())
png(paste0(para, "sentieon_eas_colored_only.png"), width = 11.6, height = 6.8, units = "in", res = 500, type = "cairo")
print(dragen_eas_color_only_plt)
