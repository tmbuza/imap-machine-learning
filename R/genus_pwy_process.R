library(tidyverse, suppressPackageStartupMessages())
library(broom)
library(ggtext)
library(data.table)

set.seed(2022)

shared <- read_csv("data/HypertensionProject.csv", show_col_types = F) %>%
  dplyr::select(1, Prevotella:ncol(.)) %>%
  data.table::transpose(keep.names = "taxonomy", make.names = "SampleID") %>%
  # select(taxonomy, starts_with("ERR")) %>%
  pivot_longer(-taxonomy, names_to="sample_id", values_to="rel_abund") %>%
  relocate(sample_id)

metabolites <- read_csv("data/HypertensionProject.csv", show_col_types = F) %>%
  dplyr::select(c(1,5:18 )) %>%
  data.table::transpose(keep.names = "metabopwy", make.names = "SampleID") %>%
  # select(metabopwy, starts_with("ERR")) %>%
  pivot_longer(-metabopwy, names_to="sample_id", values_to="value") %>%
  relocate(sample_id)

taxonomy <- read_tsv("data/mo_demodata/baxter.cons.taxonomy", show_col_types = F) %>%
  rename_all(tolower) %>%
  select(otu, taxonomy) %>%
  mutate(otu = tolower(otu),
         taxonomy = str_replace_all(taxonomy, "\\(\\d+\\)", ""),
         taxonomy = str_replace(taxonomy, ";unclassified", "_unclassified"),
         taxonomy = str_replace_all(taxonomy, ";unclassified", ""),
         taxonomy = str_replace_all(taxonomy, ";$", ""),
         taxonomy = str_replace_all(taxonomy, ".*;", "")
  )

metadata <- read_csv("data/HypertensionProject.csv", show_col_types = F) %>%
  dplyr::select(c(1:3)) %>%
  mutate(prehyper = Disease_State == "pHTN",
         hyper = Disease_State == "HTN",
         control = Disease_State == "Control") %>%
  rename(sample_id = SampleID)

## Data joining

composite <- inner_join(shared, metadata, by="sample_id")

metabo_composite <- inner_join(shared, metabolites, by="sample_id") %>%
  group_by(sample_id, metabopwy) %>%
  summarize(value = sum(value), .groups="drop") %>%
  group_by(sample_id) %>%
  mutate(rel_abund = value / sum(value)) %>%
  ungroup() %>%
  select(-value) %>%
  inner_join(., metadata, by="sample_id")
