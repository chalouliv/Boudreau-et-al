# ------------------------------------------------------------
# Script Name: plot_admixture.R
# Description: Visualization of ADMIXTURE
# Author: Charlotte Livingston
# Email: charlotte.livingston@mail.mcgill.ca
# Date: 2025-09-01
# Manuscript: Boudreau et al. (Extended carrier screening in the Acadian population)
# ------------------------------------------------------------


library(dplyr)
library(ggplot2)
library(tidyr)
library(ggnewscale)
library(RColorBrewer)
library(ggrepel) 

setwd("path/to/WORK_DIR")

#------------------------------------------------------------------------------#
### ERROR ELBOW ####
#------------------------------------------------------------------------------#

# Read CV errors from log files
cv_errors <- data.frame(K = numeric(), CV = numeric())

for (k in 1:12) {
  log_file <- paste0("input.", k, ".log")
  lines <- readLines(log_file, warn = FALSE)

  # Find line
  cv_line <- grep("CV error", lines, value = TRUE)
  
  # Extract error
  if (length(cv_line) > 0) {
    cv_value <- as.numeric(sub(".*CV error.*: ([0-9.]+)", "\\1", cv_line))
    cv_errors <- rbind(cv_errors, data.frame(K = k, CV = cv_value))
  } else {
    warning(paste("CV error not found in", log_file))
    cv_errors <- rbind(cv_errors, data.frame(K = k, CV = NA))
  }
}

# Plot
p1 <- ggplot(cv, aes(x = K, y = CV)) +
  geom_line(linetype = "dashed")+
  geom_point()+
  ylab("Cross-Validation Error")+
  xlab("K")+
  scale_x_continuous(breaks = c(2:20))+
  theme_classic() +
  theme(axis.title = element_text(face = "bold"))

ggsave("error_elbow.png", p1, width = 8, height = 8, units = "cm")

#------------------------------------------------------------------------------#
### LOAD ADMIXTURE RESULTS ###
#------------------------------------------------------------------------------#

# Read in sample IDs
fam_file = read.table("input/input.fam", header = FALSE)
fam_file = fam_file %>%
  select(V2) %>%
  rename(IID = V2)

# Read in study IDs
NB_samples = read.table("path/to/NB_samples.txt", header = FALSE)
NB_samples = NB_samples %>%
  select(V2) %>%
  rename(IID = V2) %>%
  mutate(subpop = "NB", genetic_region = "NB") 

# Identify undefined predicted ancestry group
NB_UND <- c("sample,ids,of,NB_UND")
NB_samples$subpop = mapply(function(iid, subpop) {
  if (iid %in% NB_UND) {
    "NB_UND"}
  else "NB_EUR"
}, NB_samples$IID, NB_samples$subpop)
NB_samples$pop <- NB_samples$genetic_region


# Read in reference IDs
ref_meta = read.csv("path/to/reference/metadata.csv", header = TRUE, sep = "\t")
ref_regions = rbind(ref_meta$s, ref_meta$hgdp_tgp_meta.Genetic.region, ref_meta$hgdp_tgp_meta.Genetic.region, ref_meta$hgdp_tgp_meta.Population) %>% t()
colnames(ref_regions) =c("IID", "genetic_region", "subpop", "pop")

merged_pops = rbind(ref_regions, NB_samples)
merged_pops <- merged_pops[match(fam_file$IID, merged_pops$IID), ]

all_K = data.frame(IID = character(),
                   subpop = character(),
                   genetic_region = character(),
                   K = numeric(),
                   Q = numeric(),
                   admix = numeric())

## Gather admixture results 
for (k in 1:12) {
  data = read.table(paste0("input.", k, ".Q"), header = FALSE)
  colnames(data) = paste0("Q", seq(1, k))
  admix_regions = cbind(merged_pops, data)
  admix_regions$K = k 
  admix_regions = admix_regions %>%
    pivot_longer(cols = Q1:paste0("Q", k),
                 names_to = "Q",
                 names_prefix = "Q",
                 values_to = "admix")
  all_K = rbind(all_K, admix_regions)
}


#------------------------------------------------------------------------------#
### Make Admixture Plot ###
#------------------------------------------------------------------------------#

## Color palette 
cp = c("#ffd400", "#08519c","#9d74b0", "#FF0000","#006d2c","#FF69B4","#00CED1","#4B0082","#458B00","#87CEFA","#CD1076","#8B4513")

## Factor for easy plotting
pop_order <- all_K %>%
  distinct(genetic_region, pop) %>%
  arrange(genetic_region, pop) %>%
  pull(pop) 

IID_order <- all_K %>%
  distinct(IID, pop, subpop) %>%
  arrange(pop, subpop) %>%
  pull(IID)

all_K <- all_K %>%
  mutate(
    genetic_region = factor(genetic_region, levels = c("NB_UND", "NB", "EUR", "AMR", "AFR", "CSA", "EAS", "MID", "OCE")),
    subpop = factor(subpop, levels = c("NB_UND", "NB_EUR", "EUR", "AMR", "AFR", "CSA", "EAS", "MID", "OCE")),
    pop = factor(pop, levels = pop_order),
    IID = factor(IID, levels = IID_order),
    x = as.numeric(IID)
  )


# Plot with super population labels from HGDP-1KG reference set
for (i in 1:12){
  plot_df <- all_K %>% 
    filter(K == i) %>%
    group_by(IID) %>%
    mutate(Ancestry = admix / sum(admix, na.rm =TRUE)) %>% 
    ungroup()
  
  print(table(plot_df$subpop))
  
  p2 <- ggplot(plot_df, aes(x = IID, y = Ancestry, fill = reorder(Q, Ancestry))) +
    geom_bar(stat = "identity", position = "stack", width = 1) +
    scale_fill_manual(values = cp, guide = "none") + #colors for barplot 
    scale_y_continuous(limits = c(0, 1.001), expand = c(0, 0)) +
    theme_classic() +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_blank(),
          axis.line.x = element_blank(),
          legend.position = "none",
          legend.text = element_text(size = 10),
          panel.spacing = unit(0.2, "lines"),  
          strip.background = element_blank()) +
    facet_wrap(~subpop, scales = "free_x", nrow=1)
  
  ggsave(paste0("admix_k", i, ".png"), p2, width = 20, height = 4, units = "cm")
}


  
  
  

