# (PART) ML PROTOTYPES {-}

# Machine Learning Prototypes: Streamlining Microbiome Model Development and Deployment

Machine Learning Prototypes (MLPs) serve as foundational frameworks for accelerating and enhancing machine learning endeavors within the context of microbiome research. These robust solutions offer streamlined approaches for developing, deploying, and monitoring machine learning models tailored specifically for microbiome data analysis.





## Key Features of ML Prototype

Here are the essential attributes and characteristics of MLPs:

- **Robust and Open-Source:** MLPs are robust, open-source solutions designed to accelerate the development and deployment of machine learning models.

- **Comprehensive Frameworks:** Fully developed MLPs empower Data Scientists by providing comprehensive frameworks to seamlessly build, deploy, and monitor ML models.

- **Tailored to Common Use Cases:** MLPs are meticulously crafted around common industry use cases, such as Churn Prediction Monitoring and Anomaly Detection, ensuring relevance and applicability across diverse domains.

- **Built According to Best Practices:** MLPs are developed according to best practices, undergoing rigorous review and testing to guarantee reliability and performance.

- **Reproducibility:** MLPs are designed to be reproducible, offering the flexibility to retrain models or develop customized applications tailored to specific needs.

- **Advantageous Head Start:** MLPs offer a significant advantage by providing a head start in the machine learning development process.



# (PART) MODEL DEVELOPMENT {-}

# Exploratory Data Analysis (EDA)
In machine learning we start by exploring the data to understand the structure, patterns, and relationships within the data. This involves visualizing distributions, correlations, and other relevant statistics to gain insights into the dataset.

## Preprocessing Metagenomics data
Source: [PRJEB13870](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB13870). The project titled "Gut microbiota dysbiosis contributes to the development of hypertension" serves as an ideal resource for metagenomics dataset. This dataset offers valuable insights into the association between gut microbiota composition and hypertension development, a critical area of research within the fields of microbiology and cardiovascular health.

### Load necessary libraries

```r
# Load necessary libraries with suppressed startup messages
library(tidyverse, suppressPackageStartupMessages())
library(broom)
library(ggtext)
library(data.table)

# Set seed for reproducibility
set.seed(2022)
```


### Processing OTU table data

```r
otutable <- readr::read_csv("data/HypertensionProject.csv", show_col_types = FALSE) %>%
  dplyr::select(1, Prevotella:ncol(.)) %>%
  data.table::transpose(keep.names = "taxonomy", make.names = "SampleID") %>%
  tidyr::pivot_longer(-taxonomy, names_to="sample_id", values_to="rel_abund") %>%
  dplyr::relocate(sample_id)
```


### Processing metabolites data

```r
metabolites <- read_csv("data/HypertensionProjectMetabolites.csv", show_col_types = FALSE) %>%
  dplyr::select(c(1, 5:ncol(.))) %>%
  data.table::transpose(keep.names = "metabopwy", make.names = "SampleID") %>%
  tidyr::pivot_longer(-metabopwy, names_to="sample_id", values_to="value") %>%
  dplyr::group_by(sample_id) %>% 
  dplyr::mutate(rel_abund = value/sum(value)) %>% 
  dplyr::ungroup() %>% 
  dplyr::select(-value) %>% 
  dplyr::relocate(sample_id)
```


### Processing taxonomy data

```r
taxonomy <- readr::read_tsv("data/mo_demodata/baxter.cons.taxonomy", show_col_types = FALSE) %>%
  dplyr::rename_all(tolower) %>%
  dplyr::select(otu, taxonomy) %>%
  dplyr::mutate(taxonomy = stringr::str_replace_all(taxonomy, "\\(\\d+\\)", ""),
         taxonomy = stringr::str_replace(taxonomy, ";unclassified", "_unclassified"),
         taxonomy = stringr::str_replace_all(taxonomy, ";unclassified", ""),
         taxonomy = stringr::str_replace_all(taxonomy, ";$", ""),
         taxonomy = stringr::str_replace_all(taxonomy, ".*;", ""))
```


### Processing metadata

```r
metadata <- readr::read_csv("data/HypertensionProject.csv", show_col_types = FALSE) %>%
  dplyr::select(c(1:3)) %>%
  dplyr::mutate(hyper = Disease_State == "HTN" | Disease_State == "pHTN",
         control = Disease_State == "healthy") %>%
  dplyr::rename(sample_id = SampleID)
```


## Joining metagenomics data

### Join metadata with OTU table


```r
# Join metadata with OTU table to create composite dataset
composite <- dplyr::inner_join(metadata, otutable, by="sample_id")
head(composite)
# A tibble: 6 × 7
  sample_id  Disease_State Enterotype   hyper control taxonomy         rel_abund
  <chr>      <chr>         <chr>        <lgl> <lgl>   <chr>                <dbl>
1 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Prevotella         5.53e-1
2 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Faecalibacterium   1.70e-2
3 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Klebsiella         2.99e-6
4 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Roseburia          7.47e-3
5 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Bifidobacterium    1.92e-3
6 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Enterobacter       8.52e-7
```

### Join metadata with metabolites data


```r
# Join metadata with metabolites data to create composite metabolites dataset
metabo_composite <- dplyr::inner_join(metadata, metabolites, by="sample_id")
head(metabo_composite)
# A tibble: 6 × 7
  sample_id  Disease_State Enterotype   hyper control metabopwy        rel_abund
  <chr>      <chr>         <chr>        <lgl> <lgl>   <chr>                <dbl>
1 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   LPS_biosynthesis 0.00962  
2 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   LPS_transport    0.0000221
3 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   PTS              0.203    
4 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Secretion_Syste… 0.0000221
5 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Secretion_Syste… 0        
6 ERR1398068 HTN           Enterotype_1 TRUE  FALSE   Secretion_Syste… 0.000375 
```


## Preprocessing microbiome data
For an outline of the steps involved in processing and integrating microbiome (16S rRNA) OTU table, taxonomy data, and metadata, please refer to [imap-data-preparation](https://tmbuza.github.io/imap-data-preparation). Our primary dataset is sourced from the publicly available Dietswap dataset, retrieved from the microbiome package. This dataset has been preprocessed and integrated into a long-form dataframe format already.


### Import preprocessed microbiome data
```bash
# Using dietswap dataset from microbiome package
cp ../imap-data-preparation/data/phyloseq_raw_rel_psextra_df_objects.rda data

```

### Load saved data objects

```r
load("data/phyloseq_raw_rel_psextra_df_objects.rda", verbose = TRUE)
Loading objects:
  ps_raw
  ps_rel
  psextra_raw
  psextra_rel
  ps_df
```


### View phyloseq object

```r
ps_raw
phyloseq-class experiment-level object
otu_table()   OTU Table:         [ 130 taxa and 222 samples ]
sample_data() Sample Data:       [ 222 samples by 8 sample variables ]
tax_table()   Taxonomy Table:    [ 130 taxa by 3 taxonomic ranks ]
phy_tree()    Phylogenetic Tree: [ 130 tips and 129 internal nodes ]
```


### View dataframe structure

```r
head(ps_df[, c(1, 4, 9, 11, 12, 13)])
# A tibble: 6 × 6
  sample_id  nationality bmi        rel_abund level  taxon                      
  <chr>      <fct>       <fct>          <dbl> <chr>  <chr>                      
1 Sample-208 AFR         overweight     0.617 phylum *Bacteroidetes*            
2 Sample-208 AFR         overweight     0.617 family *Bacteroidetes*            
3 Sample-208 AFR         overweight     0.617 genus  *Prevotella melaninogenica*
4 Sample-208 AFR         overweight     0.617 otu    *Prevotella melaninogenica*
5 Sample-212 AFR         obese          0.702 phylum *Bacteroidetes*            
6 Sample-212 AFR         obese          0.702 family *Bacteroidetes*            
```


## Processing data for machine learning

This section outlines the preprocessing steps involved in preparing data subsets tailored for machine learning analysis. The code segments transform raw data into structured formats suitable for predictive modeling. Specifically, the subsets created encompass various combinations of taxonomic or metabolic features alongside binary labels representing selected features. Each subset undergoes specific preprocessing steps, including data selection, transformation, and encoding, to ensure compatibility with machine learning algorithms.

### Data for disease state prediction 
This code snippet prepares a dataset for machine learning tasks. It selects specific columns from a composite dataset, renames some columns for clarity, pivots the data into a wider format, and finally, transforms some categorical variables into binary ones for modeling purposes. Here's a brief description:

```r
library(dplyr)
library(tidyr)

# Prepare dataset for machine learning
ml_genus_dsestate <- composite %>%
  # Select relevant columns and rename them
  select(sample_id, taxonomy, rel_abund, dsestate = Disease_State) %>%
  # Pivot data to wider format
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  # Remove sample_id
  select(-sample_id) %>%
  # Convert categorical variables to binary
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "0", "1")) %>%
  # Reorder columns with dsestate first
  select(dsestate, everything())

head(ml_genus_dsestate[1:3, 1:5])
# A tibble: 3 × 5
  dsestate Prevotella Faecalibacterium Klebsiella Roseburia
  <chr>         <dbl>            <dbl>      <dbl>     <dbl>
1 0             0.553          0.0170  0.00000299   0.00747
2 0             0.217          0.285   0.0000593    0.00236
3 0             0.298          0.00443 0.00513      0.00751
```


### Data for enterotype prediction

```r

# Subset for machine learning analysis: Taxonomic genus features with enterotypes
ml_genus_enttype <- composite %>%
  select(sample_id, taxonomy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "0", "1")) %>%
  select(-dsestate) %>%
  select(enttype, everything())

head(ml_genus_enttype[1:3, 1:5])
# A tibble: 3 × 5
  enttype Prevotella Faecalibacterium Klebsiella Roseburia
  <chr>        <dbl>            <dbl>      <dbl>     <dbl>
1 0            0.553          0.0170  0.00000299   0.00747
2 0            0.217          0.285   0.0000593    0.00236
3 0            0.298          0.00443 0.00513      0.00751
```

### Data for nationality prediction

```r
# Dietswap dataset: Subset for machine learning analysis: Taxonomic genus features with nationality and body mass index group

# Nationality feature
ml_genus_nationality <- ps_df %>%
  select(sample_id, taxon, nationality, rel_abund) %>%
  mutate(
    taxon = str_replace_all(taxon, "\\*", ""),
    nationality = factor(if_else(nationality == "AAM", "0", "1"), levels = c("0", "1")),) %>%
  group_by(sample_id, taxon, nationality) %>%
  summarise(rel_abund = mean(rel_abund), .groups = "drop") %>%
  pivot_wider(names_from = taxon, values_from = rel_abund) %>%
  ungroup() %>%
  filter(!is.na(nationality)) %>%  # Remove rows with NA in the 'nationality' column
  select(-c(sample_id)) %>%
  mutate(across(starts_with("rel_abund"), as.numeric))

head(ml_genus_nationality[1:3, 1:5])
# A tibble: 3 × 5
  nationality Actinobacteria Akkermansia `Alcaligenes faecalis` Allistipes
  <fct>                <dbl>       <dbl>                  <dbl>      <dbl>
1 0                 0.00121      0.00213               0.000118    0.0397 
2 1                 0.000533     0.00724               0.000406    0.00180
3 1                 0.00123      0.136                 0.000420    0.00897
```


### Data for body mass index prediction

>Dataset: Dietswap from microbiome R package


```r
ml_genus_bmi <- ps_df %>%
  select(sample_id, taxon, rel_abund, bmi) %>%
  mutate(
    taxon = str_replace_all(taxon, "\\*", ""),
    bmi = factor(if_else(bmi == "overweight" | bmi == "obese", "0", "1"), levels = c("0", "1"))
  ) %>%
  group_by(sample_id, taxon, bmi) %>%
  summarise(rel_abund = mean(rel_abund), .groups = "drop") %>%
  pivot_wider(names_from = taxon, values_from = rel_abund) %>%
  ungroup() %>%
  filter(!is.na(bmi)) %>%  # Remove rows with NA in the 'bmi' column
  select(-c(sample_id)) %>%
  mutate(across(starts_with("rel_abund"), as.numeric))

head(ml_genus_bmi[1:3, 1:5])
# A tibble: 3 × 5
  bmi   Actinobacteria Akkermansia `Alcaligenes faecalis` Allistipes
  <fct>          <dbl>       <dbl>                  <dbl>      <dbl>
1 0           0.00121      0.00213               0.000118    0.0397 
2 1           0.000533     0.00724               0.000406    0.00180
3 1           0.00123      0.136                 0.000420    0.00897
```



### Save the processed data into RDA objects

```r
save(composite,
     metabo_composite,
     ml_genus_dsestate,
     ps_df,
     ml_genus_enttype, 
     ml_genus_nationality, 
     ml_genus_bmi, 
     file = "data/ml_n_composite_object.rda")
```


<div class="alerticon">
<p><strong>Note for users:</strong></p>
<blockquote>
<p>If you encounter issues during data processing where pivot_wider()
returns values as &lt;list&gt;, it may be due to multiple values for the
same combination of identifiers (e.g., sample ID and feature). In such
cases, consider aggregating the values using group_by() and summarise()
before pivoting.</p>
</blockquote>
<p>Example:</p>
<p>ps_df %&gt;% select(sample_id, taxon, nationality, rel_abund, bmi)
%&gt;% mutate(taxon = str_replace_all(taxon, “\*“,”“)) %&gt;%
group_by(sample_id, taxon, nationality, bmi) %&gt;% summarise(rel_abund
= mean(rel_abund), .groups =”drop”) %&gt;% pivot_wider(names_from =
taxon, values_from = rel_abund) %&gt;% mutate(nationality =
if_else(nationality == “AAM”, “0”, “1”)) %&gt;% mutate(bmi = if_else(bmi
== “overweight” | bmi == “obese” , “0”, “1”)) %&gt;%
select(-c(sample_id, bmi))</p>
<blockquote>
<p>This ensures that the rel_abund values are properly aggregated before
pivoting.</p>
</blockquote>
</div>

