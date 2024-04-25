# (APPENDIX) APPENDIX {-}

# Modeling Ideas

In this case study, we explore the performance of a predictive model developed to assess the likelihood of cancer in patients based on various medical records. The model incorporated patient demographics, medical history, vital signs, and diagnostic test results. When tested on a held-out dataset, it demonstrated exceptional accuracy during evaluation.

However, upon deployment to predict cancer likelihood for new patients, the model exhibited significant discrepancies in performance. This discrepancy led to an investigation to uncover potential causes for the observed inconsistency.

## Identifying the Issue

Upon closer examination, it became evident that the model's poor performance on new patients was attributed to information leakage. Specifically, one feature in the model inadvertently exposed sensitive information, which influenced the predictions. This form of information leakage compromised the model's ability to generalize to unseen data effectively.

## Implications

Information leakage poses serious implications for the predictive model's reliability and fairness. By inadvertently incorporating sensitive information, such as patient-specific details or external factors related to the prediction task, the model's performance on new data can be compromised. This can lead to inaccurate predictions and potentially harmful outcomes if relied upon in clinical decision-making.

## Recommendations

Conducting thorough feature selection and validation processes is imperative to address information leakage and ensure the model's robustness and generalizability. This involves identifying and removing features that may inadvertently expose sensitive information or introduce bias into the model. Additionally, implementing rigorous data preprocessing techniques and adhering to best practices in model development can help mitigate the risk of information leakage and enhance the reliability of predictive models.

By prioritizing transparency, fairness, and ethical considerations throughout the model development process, we can mitigate the risks associated with information leakage and build accurate and trustworthy predictive models.


## Some Effective [ML Guidelines](https://developers.google.com/machine-learning/crash-course/real-world-guidelines)
- Keep the first model simple.
- Focus on ensuring data pipeline correctness.
- Use a simple, observable metric for training & evaluation.
- Own and monitor your input features
- Treat your model configuration as code: review it, check it in
- Write down the results of all experiments, especially "failures"






# Using ML helper function

```r
load("data/ml_n_composite_object.rda", verbose = TRUE)
Loading objects:
  composite
  metabo_composite
  ml_genus_dsestate
  ps_df
  ml_genus_enttype
  ml_genus_nationality
  ml_genus_bmi
```

> How do you know what are the different hyperparameter options are and what are the dafault values for the different modeling approaches


```r
library(mikropml)

get_hyperparams_list(ml_genus_nationality, "glmnet")
$lambda
[1] 1e-04 1e-03 1e-02 1e-01 1e+00 1e+01

$alpha
[1] 0
get_hyperparams_list(ml_genus_nationality, "rf")
$mtry
[1]  6 12 24
get_hyperparams_list(ml_genus_nationality, "svmRadial")
$C
[1] 1e-03 1e-02 1e-01 1e+00 1e+01 1e+02

$sigma
[1] 1e-06 1e-05 1e-04 1e-03 1e-02 1e-01
get_hyperparams_list(ml_genus_nationality, "rpart2") # Decision tree
$maxdepth
[1]  1  2  4  8 16 30
get_hyperparams_list(ml_genus_nationality, "xgbTree") # XGBoost
$nrounds
[1] 100

$gamma
[1] 0

$eta
[1] 0.001 0.010 0.100 1.000

$max_depth
[1]  1  2  4  8 16 30

$colsample_bytree
[1] 0.8

$min_child_weight
[1] 1

$subsample
[1] 0.4 0.5 0.6 0.7
```


# IMAP GitHub Repos

<div class="tmbinfo">
<table>
<colgroup>
<col width="29%" />
<col width="36%" />
<col width="34%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">IMAP-Repo</th>
<th align="left">Description</th>
<th align="center">GH-Pages</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-project-overview/">OVERVIEW</a></td>
<td align="left">IMAP project overview</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-project-overview/">Link</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-essential-software/">PART
01</a></td>
<td align="left">Software requirements for microbiome data analysis with
Snakemake workflows</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-essential-software/">Link</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-sample-metadata/">PART 02</a></td>
<td align="left">Downloading and exploring microbiome sample metadata
from SRA Database</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-sample-metadata/">Link</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-download-sra-reads/">PART
03</a></td>
<td align="left">Downloading and filtering microbiome sequencing data
from SRA database</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-download-sra-reads/">Link</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-read-quality-control/">PART
04</a></td>
<td align="left">Quality control of microbiome next-generation
sequencing reads</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-read-quality-control/">Link</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-bioinformatics-mothur/">PART
05</a></td>
<td align="left">Microbial profiling using MOTHUR and Snakemake
workflows</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-mothur-bioinformatics/">Link</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-bioinformatics-qiime2/">PART
06</a></td>
<td align="left">Microbial profiling using QIIME2 and Snakemake
workflows</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-qiime2-bioinformatics/">Link</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-data-processing/">PART 07</a></td>
<td align="left">Processing output from 16S-based microbiome
bioinformatics pipelines</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-data-preparation/">Link</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-exploratory-analysis/">PART
08</a></td>
<td align="left">Exploratory analysis of processed 16S-based microbiome
data</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-data-exploration/">Link</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-statistical-analysis/">PART
09</a></td>
<td align="left">Statistical analysis of processed 16S-based microbiome
data</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-statistical-analysis/">Link</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-machine-learning/">PART 10</a></td>
<td align="left">Machine learning analysis of processed 16S-based
microbiome data</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-machine-learning/">Link</a></td>
</tr>
</tbody>
</table>
</div>


# Session Information

Reproducibility relies on the ability to precisely recreate the working environment, and session information serves as a vital reference to achieve this consistency. Here we record details about the R environment, package versions, and system settings of the computing environment at the time of analysis. 


```r
library(sessioninfo)

# Get session info
info <- capture.output(print(session_info()))

# Define patterns to exclude
exclude_patterns <- c("/Users/.*", "Africa/Dar_es_Salaam") # This line is location-dependent

# Exclude lines containing specific information
info_filtered <- info[!grepl(paste(exclude_patterns, collapse = "|"), info)]

# Save the filtered session info to a text file in the root directory without line numbers
cat(info_filtered, file = "session_info.txt", sep = "\n")
```
