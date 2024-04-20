#!/usr/bin/env Rscript

source("R/genus_pwy_process.R")
library("mikropml")
library("glue")


seed <- as.numeric(commandArgs(trailingOnly = TRUE))

hyper_genus_data <- composite %>%
  select(sample_id, taxonomy, rel_abund, hyper) %>%
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(hyper = if_else(hyper, "hyper", "healthy")) %>%
  select(hyper, everything())

hyper_genus_preprocess <- preprocess_data(hyper_genus_data,
                                        outcome_colname = "hyper")$dat_transformed # scale the data, mean to zero and std = 1.

test_hp <- list(alpha = 0,
                lambda = c(0.1, 1, 2, 3, 4, 5))

model <- run_ml(hyper_genus_preprocess,
       method="glmnet",
       outcome_colname = "hyper",
       kfold = 5,
       cv_times = 100,
       training_frac = 0.8,
       hyperparameters = test_hp,
       seed = seed)

saveRDS(model, file=glue("processed_data/l2_genus_{seed}.Rds"))

