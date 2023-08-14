library(dplyr)
library(ggplot2)
library(moments)
library(tidyr)
library(gridExtra)
library(ggtext)
library(DescTools)
library(scales)

scriptPath <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(scriptPath)


otf <- read.csv("./input/OTF.csv", encoding = "UTF-8")
otf$format <- "otf"

ttf = read.csv("./input/TTF.csv", encoding = "UTF-8")
ttf$format <- "ttf"

woff = read.csv("./input/WOFF.csv", encoding = "UTF-8")
woff$format <- "woff"

woff2 = read.csv("./input/WOFF2.csv", encoding = "UTF-8")
woff2$format <- "woff2"

data <- rbind(otf, ttf, woff, woff2)
data <- data %>%
  select(format, everything()) %>%
  rename(CPUCYCLES = 4, MEMALLOC = 5, WATTAGE = 6, LENGTH = 7, RALEWAY = 8, MONTSERRAT = 9, SOURCESANS = 10) %>%
  mutate_at(vars(4:10), as.numeric)



# -------------------------------------------------------------------------------------------------------
# LENGTH
# -------------------------------------------------------------------------------------------------------

boxplot <- ggplot(data, aes(x = data$format, y = data$LENGTH, fill = format, color = format)) +
  geom_boxplot() +
  xlab("Font Format") +
  ylab("Length of Interval [ms]")
ggsave("fig/length_boxplot.pdf", boxplot, width = 6, height = 4)

violin_length <- ggplot(data, aes(x = format, y = data$LENGTH, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Load Time [ms]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA)

aggregate(LENGTH ~ format, data = data, summary)

density_length <- ggplot(data, aes(x = LENGTH)) +
  geom_density(aes(fill = format, color = format), alpha = 0.1) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  xlab("Length of Interval [ms]") +
  labs(y = NULL)

density_length_with_ylab <- density_length + ylab("Density")

grid_length <- grid.arrange(violin_length, density_length_with_ylab, widths = c(2, 3))
ggsave("fig/lenght.pdf", grid_length, width = 6, height = 4)

skewness_by_format <- data %>%
  group_by(format) %>%
  summarize(
    skewness = skewness(LENGTH),
    kurtosis = kurtosis(LENGTH)
  ) %>%
  print()

# Reshape the data from wide to long format
data_long <- data %>%
  pivot_longer(cols = c(RALEWAY, MONTSERRAT, SOURCESANS), names_to = "Variable", values_to = "LoadTime")

# Create a violin plot with variables as groups and colors as within-group colors
violin_length_fonts <- ggplot(data_long, aes(x = Variable, y = LoadTime, fill = format)) +
  geom_violin(position = position_dodge(width = 0.5), width = 0.6, alpha = 0.3) +
  geom_text(x = 3, y = 30, label = "Scatter plot") +
  labs(x = "Font", y = "Load Time") +
  scale_fill_manual(values = c(otf = "#6b7a8f", ttf = "#F7882f", woff = "#F7c331", woff2 = "#DCC7AA")) +
  theme_minimal()


ggsave("fig/length_violin_font_types.pdf", violin_length_fonts, width = 6, height = 2)


anova_TIME <- aov(data$LENGTH ~ data$format)
anova_TIME %>%
  summary() %>%
  print()

anova_TIME_tukey <- anova_TIME %>% TukeyHSD()
anova_TIME_tukey %>% print()

anova_TIME %>%
  EtaSq() %>%
  print()


# -------------------------------------------------------------------------------------------------------
# CPU
# -------------------------------------------------------------------------------------------------------

boxplot <- ggplot(data, aes(x = data$format, y = data$CPUCYCLES)) +
  geom_boxplot() +
  xlab("Font Format") +
  ylab("CPU Cycles")
ggsave("fig/cpu_barplot.pdf", boxplot, width = 6, height = 4)


violin_cpu <- ggplot(data, aes(x = format, y = CPUCYCLES, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Processor Cycles [COUNT]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA)

density_cpu <- ggplot(data, aes(x = CPUCYCLES)) +
  geom_density(aes(fill = format, color = format), alpha = 0.3) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  xlab("Processor Cycles") +
  labs(y = NULL)


density_cpu_with_ylab <- density_cpu + ylab("Density")

grid_cpu <- grid.arrange(violin_cpu, density_cpu_with_ylab, widths = c(2, 3))
ggsave("fig/cpu.pdf", grid_cpu, width = 6, height = 4)

cpu_by_format <- data %>%
  group_by(format) %>%
  summarize(
    skewness = skewness(CPUCYCLES),
    kurtosis = kurtosis(CPUCYCLES)
  ) %>%
  print()


anova_CPU <- aov(data$CPUCYCLES ~ data$format)
anova_CPU %>%
  summary() %>%
  print()

anova_CPU_tukey <- anova_CPU %>% TukeyHSD()
anova_CPU_tukey %>% print()

anova_CPU %>%
  EtaSq() %>%
  print()

# -------------------------------------------------------------------------------------------------------
# MEMALLOC
# -------------------------------------------------------------------------------------------------------


violin_mem <- ggplot(data, aes(x = format, y = MEMALLOC, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Megabyte [MB]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA)

density_mem <- ggplot(data, aes(x = MEMALLOC)) +
  geom_density(aes(fill = format, color = format), alpha = 0.1) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  scale_x_continuous(labels = unit_format(unit = "K", scale = 1e-3)) +
  xlab("Memory Allocations") +
  labs(y = NULL)

density_mem_with_ylab <- density_mem + ylab("Density")

grid_mem <- grid.arrange(violin_mem, density_mem_with_ylab, widths = c(2, 3))
ggsave("fig/mem.pdf", grid_mem, width = 6, height = 4)

mem_by_format <- data %>%
  group_by(format) %>%
  summarize(
    median = median(MEMALLOC),
    sd = sd(MEMALLOC),
    skewness = skewness(MEMALLOC),
    kurtosis = kurtosis(MEMALLOC)
  ) %>%
  print()


anova_MEM <- aov(data$MEMALLOC ~ data$format)
anova_MEM %>%
  summary() %>%
  print()

anova_MEM_tukey <- anova_MEM %>% TukeyHSD()
anova_MEM_tukey %>% print()

anova_MEM %>%
  EtaSq() %>%
  print()


# -------------------------------------------------------------------------------------------------------
# Power Consumption
# -------------------------------------------------------------------------------------------------------


violin_pow <- ggplot(data, aes(x = format, y = WATTAGE, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Watt-hours [Wh]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA)

density_pow <- ggplot(data, aes(x = WATTAGE)) +
  geom_density(aes(fill = format, color = format), alpha = 0.3) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f")) +
  xlab("Watt-hours [Wh]") +
  labs(y = NULL)


density_pow_with_ylab <- density_pow + ylab("Density")

grid_pow <- grid.arrange(violin_pow, density_pow_with_ylab, widths = c(2, 3))
ggsave("fig/power.pdf", grid_pow, width = 6, height = 4)

pow_by_format <- data %>%
  group_by(format) %>%
  summarize(
    median = median(WATTAGE),
    skewness = skewness(WATTAGE),
    kurtosis = kurtosis(WATTAGE)
  ) %>%
  print()

anova_POW <- aov(data$WATTAGE ~ data$format)
anova_POW %>%
  summary() %>%
  print()

anova_POW_tukey <- anova_POW %>% TukeyHSD()
anova_POW_tukey %>% print()

anova_POW %>%
  EtaSq() %>%
  print()


# -------------------------------------------------------------------------------------------------------
# GENERAL RESOURCES
# -------------------------------------------------------------------------------------------------------

# Create a violin plot with variables as groups and colors as within-group colors
violin1 <- ggplot(data, aes(x = format, y = CPUCYCLES, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "", y = "") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  ggtitle("Processor Cycles") +
  theme(
    plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1),
    plot.margin = margin(0.2, 0, 0.2, 0, "cm")
  ) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA)

# Create a violin plot for MEMCYCLES
violin2 <- ggplot(data, aes(x = format, y = MEMALLOC, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  labs(x = "Format", y = "") +
  ggtitle("Memory Allocation Changes") +
  theme(
    plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1),
    plot.margin = margin(0.2, 0, 0.2, 0, "cm")
  ) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA)

# Create a violin plot for WATTAGE
violin3 <- ggplot(data, aes(x = format, y = WATTAGE, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  labs(x = "", y = "") +
  ggtitle("Watts per Hour") +
  theme(
    plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1),
    plot.margin = margin(0.2, 0, 0.2, 0, "cm")
  ) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA)

# Create a violin plot for Length
violin4 <- ggplot(data, aes(x = format, y = LENGTH, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  labs(x = "", y = "") +
  ggtitle("Length of Interval [ms]") +
  theme(
    plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1),
    plot.margin = margin(0.2, 0, 0.2, 0, "cm")
  ) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA)

# Arrange the violin plots side by side

grid <- grid.arrange(violin1, violin2, violin3, violin4, ncol = 4)
ggsave("fig/res_violin.pdf", grid, width = 6, height = 4)



# -------------------------------------------------------------------------------------------------------
# MEMORY
# -------------------------------------------------------------------------------------------------------

mean_values <- data %>%
  group_by(format) %>%
  summarize(
    mean_CPU = mean(CPUCYCLES, trim = 0.05),
    mean_MEM = mean(MEMALLOC, trim = 0.05),
    mean_Wattage = mean(WATTAGE, trim = 0.05),
    mean_Length = mean(LENGTH, trim = 0.05),
    MED = median(LENGTH)
  ) %>%
  as.data.frame()


anova_CPU <- aov(data$CPUCYCLES ~ data$format)
anova_MEM <- aov(data$MEMALLOC ~ data$format)
anova_WAT <- aov(data$WATTAGE ~ data$format)

print(summary(anova_CPU))
print(summary(anova_MEM))
print(summary(anova_WAT))

tukey_CPU <- TukeyHSD(aov(data$CPUCYCLES ~ data$format))
tukey_MEM <- TukeyHSD(aov(data$MEMALLOC ~ data$format))
tukey_WAT <- TukeyHSD(aov(data$WATTAGE ~ data$format))

print(tukey_CPU)
print(tukey_MEM)
print(tukey_WAT)

# -------------------------------------------------------------------------------------------------------
#  RESOURCES Grid
# -------------------------------------------------------------------------------------------------------


grid <- grid.arrange(violin_length,
  violin_cpu,
  violin_mem,
  violin_pow,
  widths = c(1, 1),
  layout_matrix = rbind(c(1, 2), c(3, 4))
)

ggsave("fig/all_performance_paramters.pdf", grid, width = 6, height = 6)
ggsave("fig/all_performance_paramters.eps", grid, width = 6, height = 6)

# -------------------------------------------------------------------------------------------------------
#  Medians and Quantiles
# -------------------------------------------------------------------------------------------------------
# Quartiles for Load-Time (LENGTH)
load_time <- aggregate(LENGTH ~ format, data = data, function(x) quantile(x, probs = c(0.25, 0.5, 0.75)))
load_time
# Quartiles for Memory (MEMALLOC)
memory <- aggregate(MEMALLOC ~ format, data = data, function(x) quantile(x, probs = c(0.25, 0.5, 0.75)))
memory
# Quartiles for CPU (CPUCYCLES)
cpu <- aggregate(CPUCYCLES ~ format, data = data, function(x) quantile(x, probs = c(0.25, 0.5, 0.75)))
cpu
# Quartiles for Watt (WATTAGE)
watt <- aggregate(WATTAGE ~ format, data = data, function(x) quantile(x, probs = c(0.25, 0.5, 0.75)))
watt

# -------------------------------------------------------------------------------------------------------
#  Simplified violin-plots
# -------------------------------------------------------------------------------------------------------

violin_length_constellation <- ggplot(data, aes(x = format, y = LENGTH, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Milliseconds [ms]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))

violin_length_constellation


fancy_scientific <- function(l) {
  # turn in to character string in scientific notation
  l <- format(l, scientific = TRUE)
  # quote the part before the exponent to keep all the digits
  l <- gsub("^(.*)e", "'\\1'e", l)
  # turn the 'e+' into plotmath format
  l <- gsub("e", "%*%10^", l)
  # return this as an expression
  parse(text = l)
}

# Create a violin plot with variables as groups and colors as within-group colors
violin_cycles_constellation <- ggplot(data, aes(x = format, y = CPUCYCLES, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "#cycles [Count]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA) +
  scale_y_continuous(labels = fancy_scientific, breaks = scales::pretty_breaks(n = 10))

violin_cycles_constellation

violin_pow_constellation <- ggplot(data, aes(x = format, y = WATTAGE, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Watt-hours [Wh]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))

violin_pow_constellation

violin_mem_constellation <- ggplot(data, aes(x = format, y = MEMALLOC, fill = format, color = format)) +
  geom_violin(alpha = 0.3) +
  labs(x = "Format", y = "Megabyte [MB]") +
  stat_summary(fun = "median", geom = "point", shape = 18, size = 3, color = "black") +
  theme(plot.title = element_textbox_simple(size = 11, halign = 0.5, lineheight = 1)) +
  scale_fill_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  scale_color_manual(values = c(woff2 = "#DCC7AA", woff = "#F7c331", otf = "#6b7a8f", ttf = "#F7882f"), guide = "none") +
  theme(legend.position = c(0.88, 0.8)) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA) +
  geom_boxplot(width = 0.2, fill = c("#6b7a8f", "#F7882f", "#F7c331", "#DCC7AA"), color = "black", outlier.shape = NA) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))

violin_mem_constellation


ggsave("fig/violin_length_constellation.pdf", violin_length_constellation, width = 6, height = 5)
ggsave("fig/violin_cycles_constellation.pdf", violin_cycles_constellation, width = 6, height = 5)
ggsave("fig/violin_pow_constellation.pdf", violin_pow_constellation, width = 6, height = 5)
ggsave("fig/violin_mem_constellation.pdf", violin_mem_constellation, width = 6, height = 5)
