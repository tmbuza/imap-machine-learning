library(tidyverse, suppressPackageStartupMessages())
library(broom)
library(ggtext)
library(data.table)

set.seed(2022)

source("R/genus_pwy_process.R")
ml_genus_dsestate <- composite %>%
  select(sample_id, taxonomy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "hyper", "control")) %>%
  mutate_if(., is.character, as.factor) %>%
  select(-enttype) %>%
  select(dsestate, everything())

ml_genus_enttype <- composite %>%
  select(sample_id, taxonomy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "hyper", "control")) %>%
  mutate_if(., is.character, as.factor) %>%
  select(-dsestate) %>%
  select(enttype, everything())

ml_pwy_dsestate <- metabo_composite %>%
  select(sample_id, metabopwy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=metabopwy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "hyper", "control")) %>%
  mutate_if(., is.character, as.factor) %>%
  select(-enttype) %>%
  select(dsestate, everything())

ml_pwy_enttype <- metabo_composite %>%
  select(sample_id, metabopwy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=metabopwy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "hyper", "control")) %>%
  mutate_if(., is.character, as.factor) %>%
  select(-dsestate) %>%
  select(enttype, everything())

save(shared,
     metabolites,
     taxonomy,
     metadata,
     composite,
     metabo_composite,
     ml_genus_dsestate,
     ml_genus_enttype,
     ml_pwy_dsestate,
     ml_pwy_enttype,
     file = "RDataRDS/Rjoined_objects4ML.RData")
