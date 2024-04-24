# (PART) ML PROTOTYPES {-}

# Machine Learning Prototypes: Streamlining Microbiome Model Development and Deployment

Machine Learning Prototypes (MLPs) serve as foundational frameworks for accelerating and enhancing machine learning endeavors within the context of microbiome research. These robust solutions offer streamlined approaches for developing, deploying, and monitoring machine learning models tailored specifically for microbiome data analysis.





## Key Features of MLPs

Here are the essential attributes and characteristics of MLPs:

- **Robust and Open-Source:** MLPs are robust, open-source solutions designed to accelerate the development and deployment of machine learning models.

- **Comprehensive Frameworks:** Fully developed MLPs empower Data Scientists by providing comprehensive frameworks to seamlessly build, deploy, and monitor ML models.

- **Tailored to Common Use Cases:** MLPs are meticulously crafted around common industry use cases, such as Churn Prediction Monitoring and Anomaly Detection, ensuring relevance and applicability across diverse domains.

- **Built According to Best Practices:** MLPs are developed according to best practices, undergoing rigorous review and testing to guarantee reliability and performance.

- **Reproducibility:** MLPs are designed to be reproducible, offering the flexibility to retrain models or develop customized applications tailored to specific needs.

- **Advantageous Head Start:** MLPs offer a significant advantage by providing a head start in the machine learning development process.


## Model Framework Visualization

Here, we present a visualization of the primary stages entailed in constructing and assessing a machine learning model for microbiome analysis, along with analogous models.


```r
library(DiagrammeR)
library(DiagrammeRsvg)

mermaid("graph TD
subgraph A
A[Data Preprocessing: Cleaning and Transformation] --> B[Exploratory Analysis]
B --> C[Features selection]
C --> D[Feature Balancing]
D --> |Multi-Model Testing| E[Model Selection]
E --> F[Parameters Tuning]
F --> G[Parameter cross Validation]
end 

subgraph B
G --> QC{Model Evaluation}
QC --> H1[ROC: Receiver Operating <br> Characteristic Curve]
QC --> H2[Precision Recall Curve]
end
", height = 800, width = 1000)
```


```{=html}
<div id="htmlwidget-354fd138371c799510d1" style="width:1000px;height:800px;" class="DiagrammeR html-widget"></div>
<script type="application/json" data-for="htmlwidget-354fd138371c799510d1">{"x":{"diagram":"graph TD\nsubgraph A\nA[Data Preprocessing: Cleaning and Transformation] --> B[Exploratory Analysis]\nB --> C[Features selection]\nC --> D[Feature Balancing]\nD --> |Multi-Model Testing| E[Model Selection]\nE --> F[Parameters Tuning]\nF --> G[Parameter cross Validation]\nend \n\nsubgraph B\nG --> QC{Model Evaluation}\nQC --> H1[ROC: Receiver Operating <br> Characteristic Curve]\nQC --> H2[Precision Recall Curve]\nend\n"},"evals":[],"jsHooks":[]}</script>
```


# (PART) MODEL DEVELOPMENT {-}

# Exploratory Data Analysis (EDA)
In machine learning we start by exploring the data to understand the structure, patterns, and relationships within the data. This involves visualizing distributions, correlations, and other relevant statistics to gain insights into the dataset.

## Example dataset 1: Metagenomics data
Source: [PRJEB13870](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB13870). The project titled "Gut microbiota dysbiosis contributes to the development of hypertension" serves as an ideal resource for metagenomics dataset. This dataset offers valuable insights into the association between gut microbiota composition and hypertension development, a critical area of research within the fields of microbiology and cardiovascular health.

**Study description**

This study employed a multifaceted approach, integrating metagenomics and metabonomics analyses alongside fecal microbiota transplantation (FMT). By investigating the dysbiosis of the gut microbiome, the study elucidated its role as a contributing factor to the pathogenesis of hypertension, primarily through alterations in metabolic effects. Through these methodologies, the research aimed to provide a comprehensive understanding of the intricate relationship between gut microbiota composition and the development of hypertension.


## Metagenomics data integration
This section outlines the steps involved in processing the OTU table, taxonomy data, metabolites, and metadata. 


```r
# Load necessary libraries with suppressed startup messages
library(tidyverse, suppressPackageStartupMessages())
library(broom)
library(ggtext)
library(data.table)

# Set seed for reproducibility
set.seed(2022)

# Read and process the OTU table data
otutable <- read_csv("data/HypertensionProject.csv", show_col_types = FALSE) %>%
  dplyr::select(1, Prevotella:ncol(.)) %>%
  data.table::transpose(keep.names = "taxonomy", make.names = "SampleID") %>%
  pivot_longer(-taxonomy, names_to="sample_id", values_to="rel_abund") %>%
  relocate(sample_id)

# Read and process the metabolites data
metabolites <- read_csv("data/HypertensionProjectMetabolites.csv", show_col_types = FALSE) %>%
  select(c(1, 5:ncol(.))) %>%
  data.table::transpose(keep.names = "metabopwy", make.names = "SampleID") %>%
  pivot_longer(-metabopwy, names_to="sample_id", values_to="value") %>%
  group_by(sample_id) %>% 
  mutate(rel_abund = value/sum(value)) %>% 
  ungroup() %>% 
  dplyr::select(-value) %>% 
  relocate(sample_id)

# Read and process the taxonomy data
taxonomy <- read_tsv("data/mo_demodata/baxter.cons.taxonomy", show_col_types = FALSE) %>%
  rename_all(tolower) %>%
  dplyr::select(otu, taxonomy) %>%
  mutate(taxonomy = str_replace_all(taxonomy, "\\(\\d+\\)", ""),
         taxonomy = str_replace(taxonomy, ";unclassified", "_unclassified"),
         taxonomy = str_replace_all(taxonomy, ";unclassified", ""),
         taxonomy = str_replace_all(taxonomy, ";$", ""),
         taxonomy = str_replace_all(taxonomy, ".*;", ""))

# Read and process the metadata
metadata <- read_csv("data/HypertensionProject.csv", show_col_types = FALSE) %>%
  dplyr::select(c(1:3)) %>%
  mutate(hyper = Disease_State == "HTN" | Disease_State == "pHTN",
         control = Disease_State == "healthy") %>%
  rename(sample_id = SampleID)

## Data joining

# Join metadata with OTU table to create composite dataset
composite <- inner_join(metadata, otutable, by="sample_id")

# Join metadata with metabolites data to create composite metabolites dataset
metabo_composite <- inner_join(metadata, metabolites, by="sample_id")
```


## Microbiome data integration
For an outline of the steps involved in processing and integrating microbiome (16S rRNA) OTU table, taxonomy data, and metadata, please refer to [imap-data-preparation](https://tmbuza.github.io/imap-data-preparation). Our primary dataset is sourced from the publicly available Dietswap dataset, retrieved from the microbiome package. This dataset has been preprocessed and integrated into a long-form dataframe format.





```r
load("data/phyloseq_raw_rel_psextra_df_objects.rda", verbose = TRUE)
Loading objects:
  ps_raw
  ps_rel
  psextra_raw
  psextra_rel
  ps_df

cat("We will use object ps_df, here is the ps_df structure\n")
We will use object ps_df, here is the ps_df structure
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



# Feature Engineering

Feature engineering is a crucial step in the machine learning pipeline where raw data is transformed into a format that enhances the performance of predictive models. This process involves creating new features, selecting relevant features, and transforming existing features to improve the model's ability to capture patterns and make accurate predictions.

Some common techniques used in feature engineering include:

- **Feature Creation:** Generating new features from existing ones, such as extracting information from text, dates, or categorical variables, or creating interaction terms between variables.
- **Feature Selection:** Identifying the most relevant features that contribute the most to the predictive power of the model while reducing dimensionality and computational complexity.
- **Feature Transformation:** Applying transformations to features to make the data more suitable for modeling, such as scaling numeric features, encoding categorical variables, or handling missing values.

By performing effective feature engineering, we can improve the performance, interpretability, and robustness of machine learning models, ultimately leading to better predictions and insights from the data.


## Processing data for machine learning

This section outlines the preprocessing steps involved in preparing data subsets tailored for machine learning analysis. The code segments transform raw data into structured formats suitable for predictive modeling. Specifically, the subsets created encompass various combinations of taxonomic or metabolic features alongside binary labels representing selected features. Each subset undergoes specific preprocessing steps, including data selection, transformation, and encoding, to ensure compatibility with machine learning algorithms.



```r
library(dplyr)
library(tidyr)

# Subset for machine learning analysis: Taxonomic genus features with disease states

ml_genus_dsestate <- composite %>%
  select(sample_id, taxonomy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "0", "1")) %>%
  select(-enttype) %>%
  select(dsestate, everything())

# Subset for machine learning analysis: Taxonomic genus features with enterotypes
ml_genus_enttype <- composite %>%
  select(sample_id, taxonomy, enttype = Enterotype, rel_abund, dsestate = Disease_State) %>%
  pivot_wider(names_from=taxonomy, values_from = rel_abund) %>%
  select(-sample_id) %>%
  mutate(enttype = if_else(enttype == "Enterotype_1", "0", "1")) %>%
  mutate(dsestate = if_else(dsestate == "pHTN" | dsestate == "HTN" , "0", "1")) %>%
  select(-dsestate) %>%
  select(enttype, everything())


# Dietswap dataset: Subset for machine learning analysis: Taxonomic genus features with nationality and body mass index group

# Nationality feature
ml_genus_nationality <- ps_df %>%
  select(sample_id, taxon, nationality, rel_abund, bmi) %>%
  mutate(
    taxon = str_replace_all(taxon, "\\*", ""),
    nationality = factor(if_else(nationality == "AAM", "0", "1"), levels = c("0", "1")),
    bmi = factor(if_else(bmi == "overweight" | bmi == "obese", "0", "1"), levels = c("0", "1"))
  ) %>%
  group_by(sample_id, taxon, nationality, bmi) %>%
  summarise(rel_abund = mean(rel_abund), .groups = "drop") %>%
  pivot_wider(names_from = taxon, values_from = rel_abund) %>%
  ungroup() %>%
  filter(!is.na(nationality)) %>%  # Remove rows with NA in the 'nationality' column
  select(-c(sample_id, bmi)) %>%
  mutate(across(starts_with("rel_abund"), as.numeric))

# Body mass index feature
ml_genus_bmi <- ps_df %>%
  select(sample_id, taxon, nationality, rel_abund, bmi) %>%
  mutate(
    taxon = str_replace_all(taxon, "\\*", ""),
    nationality = factor(if_else(nationality == "AAM", "0", "1"), levels = c("0", "1")),
    bmi = factor(if_else(bmi == "overweight" | bmi == "obese", "0", "1"), levels = c("0", "1"))
  ) %>%
  group_by(sample_id, taxon, nationality, bmi) %>%
  summarise(rel_abund = mean(rel_abund), .groups = "drop") %>%
  pivot_wider(names_from = taxon, values_from = rel_abund) %>%
  ungroup() %>%
  filter(!is.na(bmi)) %>%  # Remove rows with NA in the 'bmi' column
  select(-c(sample_id, nationality)) %>%
  mutate(across(starts_with("rel_abund"), as.numeric))

# Save the processed data objects into an RDA file for downstream analysis
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


## Feature Selection

- **Objective**: Perform feature selection to identify relevant microbial taxa or functional pathways associated with the binary outcome of interest, such as disease status or treatment response.
- **Techniques**: Utilize methods like Lasso regularization, Recursive Feature Elimination (RFE), and Boruta algorithm to automatically select important features and penalize less informative ones, enhancing model interpretability and performance.


## Feature Selection Techniques

- **Variance Threshold**: Identify features with low variance, which may be less informative for the model, and remove them from consideration.
- **Univariate Selection**: Evaluate the relationship between each feature and the target variable independently, selecting the most relevant features based on statistical tests.
- **Recursive Feature Elimination (RFE)**: Iteratively remove the least significant features from the model until the optimal subset of features is achieved, based on model performance metrics.
- **Principal Component Analysis (PCA)**: Transform the original features into a lower-dimensional space while retaining most of the variance, effectively reducing the dimensionality of the data and identifying important patterns.
- **Feature Importance**: Assess the importance of each feature based on its contribution to model performance, using techniques like Random Forest feature importance or permutation importance.


## Variance threshold

```r
library(tidyverse)

# Example dataset (replace with your own data)
data <- ml_genus_nationality
# data <- ml_genus_bmi
# data <- ml_genus_enttype
# data <- ml_genus_dsestate

# Calculate variance for each feature
variances <- apply(data[, -1], 2, var)  # Exclude the first column (nationality)

# Set the threshold for variance
threshold <- 0.0001  # Adjust as needed

# Identify features with variance above the threshold
selected_features <- names(variances[variances > threshold])

# Remove NA values from selected_features
selected_features <- selected_features[!is.na(selected_features)]

# Add the first column (nationality) to the selected features
selected_features <- c("nationality", selected_features)

# Filter dataset to include selected features
filtered_data <- data[, colnames(data) %in% selected_features]

# Display filtered dataset
head(filtered_data[, 1:5])
# A tibble: 6 × 5
  nationality Akkermansia Allistipes `Bacteroides fragilis` `Bacteroides ovatus`
  <fct>             <dbl>      <dbl>                  <dbl>                <dbl>
1 0              0.00213     0.0397                 0.0524              0.0505  
2 1              0.00724     0.00180                0.00151             0.000637
3 1              0.136       0.00897                0.0729              0.00518 
4 1              0.00101     0.00299                0.00139             0.00112 
5 1              0.00490     0.00713                0.00312             0.00279 
6 1              0.000706    0.00116                0.00116             0.000899



library(dplyr)
library(caret)
library(mikropml)

training_data <- filtered_data %>%
  dplyr::rename(target = nationality) %>% 
  mutate(target = recode_factor(target, "0" = "AAM", "1" = "AFR"))
```

> Note: NA values must be removed from the selected_features vector before filtering the dataset to avoid errors.


# (PART) MODEL TRAINING {-}

# Data Splitting
The dataset is divided into separate subsets for training and testing. This partitioning allows for an unbiased evaluation of the model's performance on unseen data, helping to assess its ability to generalize to new observations.

**Using caret::createDataPartition() function**


```r
set.seed(1234)

# Load necessary libraries
library(caret)

# Example dataset (replace with your own data)
data <- training_data

# Split data into training and testing sets
set.seed(123) # for reproducibility
train_index <- caret::createDataPartition(data$target, p = 0.8, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

cat("\nDimension of the test data using caret package\n is", base::dim(test_data)[1], "rows and", base::dim(test_data)[2], "columns.\n")

Dimension of the test data using caret package
 is 43 rows and 27 columns.
cat("\nDimension of the train data using caret package\n is", base::dim(train_data)[1], "rows and", base::dim(train_data)[2], "columns.\n")

Dimension of the train data using caret package
 is 179 rows and 27 columns.

cat("\nThe intersection between test and train dataset is", nrow(test_data %>% intersect(train_data)))

The intersection between test and train dataset is 0
```

**Using dplyr::sample_n() and dplyr::setdiff() functions**


```r
set.seed(123)

library(dplyr)
test_df = training_data %>% dplyr::sample_n(0.2*nrow(training_data))
train_df = training_data %>% dplyr::setdiff(test_df)

cat("\nDimension of the test data using dplyr package\n is", base::dim(test_df)[1], "rows and", base::dim(test_df)[2], "columns.\n")

Dimension of the test data using dplyr package
 is 44 rows and 27 columns.
cat("\nDimension of the train data using dplyr package\n is", base::dim(train_df)[1], "rows and", base::dim(train_df)[2], "columns.\n")

Dimension of the train data using dplyr package
 is 178 rows and 27 columns.


cat("\nThe intersection between test and train dataset is", nrow(test_df %>% intersect(train_df)))

The intersection between test and train dataset is 0
```

**Visualize the relative abundance of selected microbes in the training and testing datasets**


```r
library(dplyr)
library(ggplot2)
library(ggpubr)

cols <- c("AAM" = "red","AFR" = "green4")

p1 <- train_data %>% ggplot(aes(x = `Bacteroides vulgatus`, y = `Prevotella melaninogenica`, color = factor(target))) + geom_point(size = 2, shape = 16, alpha = 0.6) +
  labs(title = "Train Dataset using \ncaret::createDataPartition() function") +
  scale_colour_manual(values = cols, labels = c("African American", "Africa"), name="Level") +
  theme_bw() +
  theme(text = element_text(size = 8))

p2 <- test_data %>% ggplot(aes(x = `Bacteroides vulgatus`, y = `Prevotella melaninogenica`, color = factor(target))) + geom_point(size = 2, shape = 16, alpha = 0.6) +
  labs(title = "Test Dataset using \ncaret::createDataPartition() function") +
  scale_colour_manual(values = cols, labels = c("African American", "Africa"), name="Level") +
  theme_bw() +
  theme(text = element_text(size = 8))


p3 <- train_df %>% ggplot(aes(x = `Bacteroides vulgatus`, y = `Prevotella melaninogenica`, color = factor(target))) + geom_point(size = 2, shape = 16, alpha = 0.6) +
  labs(title = "Train Dataset using dplyr::sample_n() \nand dplyr::setdiff() functions") +
  scale_colour_manual(values = cols, labels = c("African American", "Africa"), name="Level") +
  theme_bw() +
  theme(text = element_text(size = 8))

p4 <- test_df %>% ggplot(aes(x = `Bacteroides vulgatus`, y = `Prevotella melaninogenica`, color = factor(target))) + geom_point(size = 2, shape = 16, alpha = 0.6) +
  labs(title = "Test Dataset using dplyr::sample_n() \nand dplyr::setdiff() functions") +
  scale_colour_manual(values = cols, labels = c("African American", "Africa"), name="Level") +
  theme_bw() +
  theme(text = element_text(size = 8))

# Arrange plots using ggpubr
ggarrange(p1, p2, p3, p4, nrow = 2, ncol = 2, common.legend = TRUE, legend = "right", heights = c(1, 1))
```

<img src="./figures/unnamed-chunk-9-1.png" width="768" />



# Model Fitting

Microbiome data presents unique challenges and opportunities for modeling due to its high dimensionality and complexity. In this section, we explore various algorithms suitable for modeling microbiome datasets:

## Regularized Logistic Regression
Regularized Logistic Regression is a variant of logistic regression tailored for binary classification tasks commonly encountered in microbiome studies. It introduces penalty terms such as Lasso (L1) and Ridge (L2) to control model complexity and prevent overfitting.


```r
set.seed(1234)

mod_regLogistic_cv <- train(target ~ ., data = training_data,
                            method = "regLogistic",
                            tuneLength = 12,
                            trControl = caret::trainControl(method = "adaptive_cv",
                                                             verboseIter = FALSE),
                            tuneGrid = base::expand.grid(cost = seq(0.001, 1, length.out = 20),
                                                         loss =  "L2_primal",
                                                         epsilon = 0.01 ))
```


**Regularized Logistic Regression model performance during training (using metrics like accuracy)**


```r
set.seed(1234)
## Visualize the model performance

library(ggplot2)


# Plot Accuracy vs. cost for Regularized Logistic Regression Model (Adaptive CV)
ggplot(mod_regLogistic_cv$results, aes(x = cost, y = Accuracy)) +
  geom_line(color = "blue") +
  geom_point(color = "black") +
  labs(title = "Accuracy vs. Cost for Regularized Logistic Regression Model (Adaptive CV)",
       x = "Cost", y = "Accuracy") +
  theme_bw()
```

<img src="./figures/unnamed-chunk-11-1.png" width="672" />

## Generalized Linear Models (glmnet)
glmnet is a package in R that fits Generalized Linear Models with Lasso or Elastic-Net regularization. It's particularly useful for microbiome data analysis due to its ability to handle high-dimensional datasets with sparse features.


```r
set.seed(1234)
mod_glmnet_adcv <- train(target ~ ., data = training_data,
             method = "glmnet",
             tuneLength = 12,
             trControl = caret::trainControl(method = "adaptive_cv"))
```


**Generalized Linear model performance during training (using metrics like accuracy)**


```r
set.seed(1234)
## Visualize the model performance

library(ggplot2)


# Plot Accuracy vs. lambda for glmnet Model (Adaptive CV)
ggplot(mod_glmnet_adcv$results, aes(x = lambda, y = Accuracy)) +
  geom_line(color = "blue") +
  geom_point(color = "black") +
  labs(title = "Accuracy vs. Lambda for glmnet Model (Adaptive CV)",
       x = "Lambda", y = "Accuracy") +
  theme_bw()
```

<img src="./figures/unnamed-chunk-13-1.png" width="672" />


## Random Forest
Random Forest is an ensemble learning technique that combines multiple decision trees to improve predictive performance. It's well-suited for handling the high-dimensional and nonlinear nature of microbiome data while mitigating overfitting.



```r
set.seed(1234)
mod_rf_reptcv <- train(target ~ ., data = training_data,
             method = "rf",
             tuneLength = 12,
             trControl = caret::trainControl(method = "repeatedcv"))


mod_rf_adcv <- train(target ~ ., data = training_data,
             method = "rf",
             tuneLength = 12,
             trControl = caret::trainControl(method = "adaptive_cv",
                      verboseIter = FALSE))
```


**Random Forest model performance during training (using metrics like accuracy)**


```r
set.seed(1234)
## Visualize the model performance

library(ggplot2)


# Plot Accuracy vs. mtry for Random Forest Model (Repeated CV)
ggplot(mod_rf_reptcv$results, aes(x = mtry, y = Accuracy)) +
  geom_line(color = "blue") +
  geom_point(color = "black") +
  labs(title = "Accuracy vs. mtry for Random Forest Model (Repeated CV)",
       x = "mtry", y = "Accuracy") +
  theme_bw()
```

<img src="./figures/unnamed-chunk-15-1.png" width="672" />

```r

# Plot Accuracy vs. mtry for Random Forest Model (Adaptive CV)
ggplot(mod_rf_adcv$results, aes(x = mtry, y = Accuracy)) +
  geom_line(color = "blue") +
  geom_point(color = "black") +
  labs(title = "Accuracy vs. mtry for Random Forest Model (Adaptive CV)",
       x = "mtry", y = "Accuracy") +
  theme_bw()
```

<img src="./figures/unnamed-chunk-15-2.png" width="672" />



## k-Nearest Neighbors (kNN)
kNN is a simple yet effective algorithm for classification and regression tasks in microbiome studies. It works by assigning a class label to an unclassified sample based on the majority class of its k nearest neighbors in the feature space.



```r
set.seed(1234)
mod_knn_reptcv <- train(target ~ ., data = training_data,
                        method = "knn",
                        tuneLength = 12,
                        trControl = caret::trainControl(method = "repeatedcv",
                                                         repeats = 2))


mod_knn_adcv <- train(target ~ ., data = training_data,
                      method = "knn",
                      tuneLength = 12,
                      trControl = caret::trainControl(method = "adaptive_cv",
                                                       repeats = 2,
                                                       verboseIter = FALSE))
```



**k-Nearest Neighbors model performance during training (using metrics like accuracy)**


```r
set.seed(1234)
## Visualize the model performance

library(ggplot2)

# Plot Accuracy vs. k for KNN Model (Repeated CV)
ggplot(mod_knn_reptcv$results, aes(x = k, y = Accuracy)) +
  geom_line(color = "blue") +
  geom_point(color = "black") +
  labs(title = "Accuracy vs. k for KNN Model (Repeated CV)",
       x = "k", y = "Accuracy") +
  theme_bw()
```

<img src="./figures/unnamed-chunk-17-1.png" width="672" />

```r

# Plot Accuracy vs. k for KNN Model (Adaptive CV)
ggplot(mod_knn_adcv$results, aes(x = k, y = Accuracy)) +
  geom_line(color = "blue") +
  geom_point(color = "black") +
  labs(title = "Accuracy vs. k for KNN Model (Adaptive CV)",
       x = "k", y = "Accuracy") +
  theme_bw()
```

<img src="./figures/unnamed-chunk-17-2.png" width="672" />



```r
if(!dir.exists("models")) {dir.create("models")}
save(mod_glmnet_adcv, mod_regLogistic_cv, mod_rf_adcv, mod_rf_reptcv, mod_knn_adcv, mod_knn_reptcv, file = "models/models.rda")
```


## Decision Trees
Decision Trees offer an intuitive approach to modeling microbiome data by recursively partitioning the feature space based on microbial abundance levels. While susceptible to overfitting, decision trees provide insights into the hierarchical structure of microbiome communities.

## Support Vector Machines (SVM)
SVM is a powerful algorithm for classifying microbiome samples based on their microbial composition. By finding the optimal hyperplane that separates different microbial communities, SVM can effectively discern complex patterns in microbiome data.

## Neural Networks
Neural Networks, including Deep Learning architectures, offer a flexible framework for modeling microbiome datasets. These models can capture intricate relationships between microbial taxa and host phenotypes, making them valuable for tasks such as disease classification and biomarker discovery.

## Gradient Boosting Machines (GBM)
GBM is an ensemble learning method that builds a sequence of decision trees to gradually improve predictive accuracy. It's adept at handling complex interactions between microbial taxa and host factors, making it suitable for microbiome classification tasks.

## AdaBoost
AdaBoost is a boosting algorithm that combines multiple weak learners to create a strong classifier. It's particularly useful for microbiome data classification due to its ability to focus on difficult-to-classify samples and improve overall model performance.

## Naive Bayes
Naive Bayes is a probabilistic classifier based on Bayes' theorem and the assumption of independence between features. While its simplicity makes it computationally efficient, Naive Bayes can still provide competitive performance for microbiome classification tasks.

<div class="infoicon">
<blockquote>
<p>In certain models that utilize lambda, such as Regularized Logistic
Regression models, we have the capability to set lambda using
expressions to define a sequence of numerical values. For instance,
employing the expression 10^seq(-3, 3, by = 0.5) results in the
generation of numbers through raising 10 to the power of each element
within the sequence ranging from -3 to 3, with an increment of 0.5. The
output presents a sequence of values, such as 10^-3, 10^-2.5, 10^-2,
10^-1.5, 10^-1, 10^-0.5, 10^0, 10^0.5, 10^1, 10^1.5, 10^2, 10^2.5, and
10^3.</p>
</blockquote>
</div>


## Cross-Validation Techniques

Cross-validation is a method used to evaluate the performance and generalization ability of predictive models. It involves partitioning the available data into multiple subsets, known as folds. The model is trained on a portion of the data (training set) and then evaluated on the remaining data (validation set). This process is repeated multiple times, with each fold serving as the validation set exactly once. Cross-validation provides a more robust estimate of the model's performance compared to a single train-test split and helps identify overfitting.

In this section, we will explore various cross-validation techniques. Understanding these methods is essential as they play a significant role in subsequent hyperparameter tuning. Cross-validation ensures robust model evaluation and assists in selecting optimal hyperparameters for improved model performance.

## K-Fold Cross-Validation

K-Fold Cross-Validation divides the data into K equal-sized folds. The model is trained K times, each time using K-1 folds as the training set and the remaining fold as the validation set.


```r
# Example of K-Fold Cross-Validation
kfcv_ctrl <- caret::trainControl(method = "cv", number = 10)

```

## Leave-One-Out Cross-Validation (LOOCV)
Leave-One-Out Cross-Validation involves using a single observation as the validation set and the remaining observations as the training set. This process is repeated for each observation in the dataset.


```r
# Example of Leave-One-Out Cross-Validation
loocv_ctrl <- caret::trainControl(method = "LOOCV")
```

## Stratified Cross-Validation
Stratified Cross-Validation ensures that each fold maintains the same class distribution as the original dataset. It is particularly useful for imbalanced datasets.


```r
# Example of Stratified Cross-Validation
strcv_ctrl <- trainControl(method = "cv", 
                     number = 10, 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)
```

## Nested Cross-Validation
Nested Cross-Validation is used to tune hyperparameters and evaluate model performance simultaneously. It involves an outer loop for model evaluation using K-Fold Cross-Validation and an inner loop for hyperparameter tuning.


```r
# Example of Nested Cross-Validation
nestcv_ctrl_outer <- trainControl(method = "cv", number = 5)
netscv_ctrl_inner <- trainControl(method = "cv", number = 3)
```

# Hyperparameter Tuning
In this stage, our objective is to refine the parameters utilized during model fitting to maximize performance. We concentrate on optimizing the model's effectiveness by fine-tuning various hyperparameters. These parameters, such as regularization strength or tree depth, are manually adjusted to enhance the model's accuracy. Through experimentation with different values, our goal is to pinpoint the optimal combination that maximizes performance on validation data. This pivotal step ensures that the model not only excels on training data but also generalizes effectively to new, unseen data.

**Parameter tuning for a RLR Model**


```r
# Set seed for reproducibility
set.seed(110912)

# Load necessary libraries
library(caret)
library(ggplot2)

# Define the tuning grid
tuneGrid <- expand.grid(
  cost = seq(0.001, 1, length.out = 20),  # Define a sequence of cost values
  loss = "L2_primal",  # Specify the loss function
  epsilon = 0.01  # Set the epsilon value
)

# Set up cross-validation method
ctrl <- trainControl(
  method = "adaptive_cv",  # Use adaptive cross-validation
  verboseIter = FALSE  # Print progress during each iteration
)

# Perform hyperparameter tuning
mod_regLogistic_cv <- train(
  target ~ .,  # Define the formula for the model
  data = training_data,  # Specify the training dataset
  method = "regLogistic",  # Choose the regularized logistic regression method
  tuneLength = 12,  # Set the number of tuning parameter combinations to try
  trControl = ctrl,  # Specify the cross-validation method
  tuneGrid = tuneGrid  # Use the defined tuning grid
)

# Visualize the model performance
ggplot(mod_regLogistic_cv$results, aes(x = cost, y = Accuracy)) +
  geom_line(color = "blue") +  # Add a line plot
  geom_point(color = "black") +  # Add points for each data point
  labs(
    title = "Accuracy vs. Cost for Regularized Logistic Regression Model (Adaptive CV)",  # Set the plot title
    x = "Cost",  # Label the x-axis
    y = "Accuracy"  # Label the y-axis
  ) +
  theme_bw()  # Apply a black and white theme
```

<img src="./figures/unnamed-chunk-24-1.png" width="672" />



## Confusion Matrix
A Confusion Matrix summarizes the performance of a classification model by tabulating the true positive, true negative, false positive, and false negative predictions.


```r
# Load necessary libraries
library(caret)
# Predict using the trained model
predictions <- predict(mod_regLogistic_cv, newdata = test_data)

# Compute confusion matrix
confusion_matrix <- caret::confusionMatrix(predictions, test_data$target)

print(confusion_matrix)
Confusion Matrix and Statistics

          Reference
Prediction AAM AFR
       AAM  19   3
       AFR   5  16
                                         
               Accuracy : 0.814          
                 95% CI : (0.666, 0.9161)
    No Information Rate : 0.5581         
    P-Value [Acc > NIR] : 0.000393       
                                         
                  Kappa : 0.6269         
                                         
 Mcnemar's Test P-Value : 0.723674       
                                         
            Sensitivity : 0.7917         
            Specificity : 0.8421         
         Pos Pred Value : 0.8636         
         Neg Pred Value : 0.7619         
             Prevalence : 0.5581         
         Detection Rate : 0.4419         
   Detection Prevalence : 0.5116         
      Balanced Accuracy : 0.8169         
                                         
       'Positive' Class : AAM            
                                         
```


# Model Performance Metrics

## Accuracy
Accuracy measures the proportion of correctly classified instances out of the total number of instances. While intuitive, accuracy may not be suitable for imbalanced datasets, where the majority class dominates the classification.

## Precision and Recall
Precision measures the proportion of correctly predicted positive instances out of all instances predicted as positive. Recall, also known as sensitivity, measures the proportion of correctly predicted positive instances out of all actual positive instances.

## F1 Score
The F1 Score is the harmonic mean of precision and recall. It provides a balanced assessment of a classifier's performance, considering both false positives and false negatives.



```r
library(caret)

# Extract accuracy and other performance metrics from confusion matrix
accuracy <- confusion_matrix$overall["Accuracy"]
precision <- confusion_matrix$byClass["Precision"]
recall <- confusion_matrix$byClass["Recall"]
f1 <- confusion_matrix$byClass["F1"]

# Create a data frame for model performance metrics
performance_metrics <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1 Score"),
  Value = c(accuracy, precision, recall, f1)
)

# Visualize model performance metrics
ggplot(performance_metrics, aes(x = Metric, y = Value)) +
  geom_bar(stat = "identity", fill = "steelblue", color = "black") +
  labs(x = "Metric", y = "Value", title = "Model Performance Metrics") +
  theme_minimal()
```

<img src="./figures/unnamed-chunk-26-1.png" width="672" />


## ROC Curve and AUC-ROC
The ROC Curve plots the true positive rate (sensitivity) against the false positive rate (1 - specificity) at various threshold settings. It provides a visual representation of the classifier's performance across different threshold levels. The Area Under the ROC Curve (AUC-ROC) quantifies the overall performance of the model in distinguishing between the positive and negative classes. A higher AUC-ROC value indicates better discrimination performance.



```r
library(pROC)
library(ggplot2)

# Compute predicted probabilities
predicted_probabilities <- predict(mod_regLogistic_cv, newdata = test_data, type = "prob")

# Extract probabilities for the positive class
positive_probabilities <- predicted_probabilities$AAM

# Compute ROC curve and AUC-ROC
roc_curve <- pROC::roc(test_data$target, positive_probabilities)
auc_roc <- pROC::auc(roc_curve)

# Plot ROC curve with descriptive axis titles
ggroc(roc_curve, color = "steelblue", size = 1) +
  labs(title = "Receiver Operating Characteristic (ROC) Curve",
       x = "False Positive Rate (1 - Specificity)",
       y = "True Positive Rate (Sensitivity)") +
  theme_minimal()
```

<img src="./figures/unnamed-chunk-27-1.png" width="672" />

```r


# Print AUC-ROC
cat("AUC-ROC:", auc_roc)
AUC-ROC: 0.8552632
```



# (PART) PERFORMANCE METRICS {-}

# Specificity and Sensitivity function


```r

library(purrr)

get_sens_spec <- function(threshold, score, actual, direction){
  
  predicted <- if(direction == "greaterthan") {
    score > threshold 
    } else {
      score < threshold
    }
  
  tp <- sum(predicted & actual)
  tn <- sum(!predicted & !actual)
  fp <- sum(predicted & !actual)
  fn <- sum(!predicted & actual)  
  
  specificity <- tn / (tn + fp)
  sensitivity <- tp / (tp + fn)
  
  tibble("specificity" = specificity, "sensitivity" = sensitivity)
}

get_roc_data <- function(x, direction){
  
  # x <- test
  # direction <- "greaterthan"
  
  thresholds <- unique(x$score) %>% sort()
  
  map_dfr(.x=thresholds, ~get_sens_spec(.x, x$score, x$srn, direction)) %>%
    rbind(c(specificity = 0, sensitivity = 1))
}
```



## Significant genera with `wilcox.test`
## Wilcoxon Rank Sum and Signed Rank Tests

The Wilcoxon rank sum test, also known as the Mann-Whitney U test, is a nonparametric test used to assess whether two independent samples have different distributions. It is particularly useful when the assumptions of the t-test are not met, such as when the data is not normally distributed or when the sample sizes are small


```r
library(purrr)
library(dplyr)
library(tidyr)

all_genera <- composite %>%
  tidyr::nest(data = -taxonomy) %>%
  mutate(test = purrr::map(.x=data, ~wilcox.test(rel_abund~hyper, data=.x) %>% tidy)) %>%
  tidyr::unnest(test) %>%
  mutate(p.adjust = p.adjust(p.value, method="BH"))

sig_genera <- all_genera %>% 
  dplyr::filter(p.value < 0.001) %>%
  arrange(p.adjust) %>% 
  dplyr::select(taxonomy, p.value)
```

## View distribution of significant genera

```r
composite %>%
  inner_join(sig_genera, by="taxonomy") %>%
  mutate(rel_abund = 100 * (rel_abund + 1/20000),
         taxonomy = str_replace(taxonomy, "(.*)", "*\\1*"),
         taxonomy = str_replace(taxonomy, "\\*(.*)_unclassified\\*",
                                "Unclassified<br>*\\1*"),
         hyper = factor(hyper, levels = c(T, F))) %>%
  ggplot(aes(x=rel_abund, y=taxonomy, color=hyper, fill=hyper)) +
  # geom_vline(xintercept = 100/10530, size=0.5, color="gray") +
  geom_jitter(position = position_jitterdodge(dodge.width = 0.8,
                                              jitter.width = 0.5),
              shape=21) +
  stat_summary(fun.data = median_hilow, fun.args = list(conf.int=0.5),
               geom="pointrange",
               position = position_dodge(width=0.8),
               color="black", show.legend = FALSE) +
  scale_x_log10() +
  scale_color_manual(NULL,
                     breaks = c(F, T),
                     values = c("gray", "dodgerblue"),
                     labels = c("Control", "Hypertension")) +
  scale_fill_manual(NULL,
                     breaks = c(F, T),
                     values = c("gray", "dodgerblue"),
                     labels = c("Control", "Hypertension")) +
  labs(x= "Relative abundance (%)", y=NULL) +
  theme_classic() +
  theme(
    axis.text.y = element_markdown()
  )
```

<img src="./figures/unnamed-chunk-30-1.png" width="672" />

```r

ggsave("figures/significant_genera.tiff", width=6, height=4)
```

## Significant pathways
Compute the significant pathways using `wilcox.test`.


```r
library(tidyverse)

all_metabopwy <- metabo_composite %>%
  tidyr::nest(data = -metabopwy) %>%
  mutate(test = purrr::map(.x=data, ~wilcox.test(rel_abund~hyper, data=.x) %>% tidy)) %>%
  tidyr::unnest(test) %>%
  mutate(p.adjust = p.adjust(p.value, method="BH"))

sig_metabopwy <- all_metabopwy %>% 
  dplyr::filter(p.value < 0.3) %>% # Typically, the best significant p-value is set at 0.05
  dplyr::select(metabopwy, p.value)
```

## View distribution of significant metabolic pathways
- Compute the significant pathways, then
- P-values or Adjusted P-values (p.adjust) can be used to measure the significance levels.
- View the distribution of the significant pathways.


```r
metabo_composite %>%
  inner_join(sig_metabopwy, by="metabopwy") %>%
  mutate(rel_abund = 100 * (rel_abund + 1/20000),
         metabopwy = str_replace(metabopwy, "(.*)", "*\\1*"),
         metabopwy = str_replace(metabopwy, "\\*(.*)_unclassified\\*",
                                "Unclassified<br>*\\1*"),
         hyper = factor(hyper, levels = c(T, F))) %>%
  ggplot(aes(x=rel_abund, y=metabopwy, color=hyper, fill=hyper)) +
  geom_jitter(position = position_jitterdodge(dodge.width = 0.8,
                                              jitter.width = 0.5),
              shape=21) +
  stat_summary(fun.data = median_hilow, fun.args = list(conf.int=0.5),
               geom="pointrange",
               position = position_dodge(width=0.8),
               color="black", show.legend = FALSE) +
  scale_x_log10() +
  scale_color_manual(NULL,
                     breaks = c(F, T),
                     values = c("gray", "dodgerblue"),
                     labels = c("Control", "Hypertension")) +
  scale_fill_manual(NULL,
                     breaks = c(F, T),
                     values = c("gray", "dodgerblue"),
                     labels = c("Control", "Hypertension")) +
  labs(x= "Relative abundance (%)", y=NULL) +
  theme_classic() +
  theme(
    axis.text.y = element_markdown()
  )
```

<img src="./figures/unnamed-chunk-32-1.png" width="672" />

```r

ggsave("figures/significant_genera.tiff", width=6, height=4)
```

> Here we filter the metabolic pathways at a lesser stringent `p.values` (p < 0.25) for demo purposes.


# (PART) MODEL DEPLOYMENT {-}

# Shiny Applications

## Model Deployment
Deploying the trained regularized logistic regression model is essential for predicting binary outcomes in microbiome studies. Additionally, implementing monitoring mechanisms is crucial to track model performance over time and detect any deviations or anomalies. This ensures continued reliability and accuracy in microbiome data analysis.

Deployment involves integrating the model into production environments where it can be utilized to predict binary outcomes based on new microbiome data. We will deploy the trained regularized logistic regression model using a Shiny web application. Shiny is a popular R package for building interactive web applications directly from R code. It allows users to visualize data, perform analyses, and make predictions in a user-friendly interface.

Shiny applications serve as interfaces for machine learning models, providing users with a convenient platform to upload their data and test the model's performance efficiently.


## Data Processing
1. Conduct various tests to ensure the functionality of the system.
2. Collect the results from these tests, which may involve multiple types of assessments.
3. Determine whether the test should be accepted or rejected based on the collected data.
4. Save the developed model for future use.

## Application Process
1. Develop a regularized logistic regression model tailored to the task.
2. Create a Shiny application incorporating the developed model.
3. Enable users to upload their test data directly to the Shiny app.
4. Visualize and download predictions generated by the model through the Shiny interface.



## Creating Shiny App

### Load regularized model

```r
load("models/models.rda", verbose = TRUE)
Loading objects:
  mod_glmnet_adcv
  mod_regLogistic_cv
  mod_rf_adcv
  mod_rf_reptcv
  mod_knn_adcv
  mod_knn_reptcv
```

### Create user interfale object
> This user interface object controls the layout and appearance of the app.




## Example APP with Qualitative data using Burro package

<div class="infoicon">
<p>library(burro)</p>
<p>library(NHANES)</p>
<p>data(NHANES)</p>
<p>NHANES %&gt;% mutate(gr = 1) %&gt;% ggplot(aes_string(x =
“AgeDecade”, fill = “AgeDecade”)) + geom_bar(aes(y = ..count..), color =
“black”) + viridis::scale_fill_viridis(discrete = TRUE, option =
“magma”) + geom_text(aes(group = gr, label = scales::percent(..prop..),
y = ..count..), stat = “count”, vjust = -0.5) + theme(axis.text.x =
element_text(angle = 90), legend.position = “none”)</p>
<p>data_dict &lt;-
readr::read_csv(system.file(“nhanes/data_dictionary.csv”,
package=“burro”))</p>
<p>outcome &lt;- c(“Depressed”)</p>
<p>explore_data(dataset=NHANES, data_dictionary=data_dict,
outcome_var=outcome)</p>
</div>