# (APPENDIX) APPENDIX {-}

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
<td align="left">Software requirement for microbiome data analysis with
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
<td align="left">Quality Control of Microbiome Next Generation
Sequencing Reads</td>
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
<td align="left">Processing Output from 16S-Based microbiome
bioinformatics pipelines</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-data-preparation/">Link</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-exploratory-analysis/">PART
08</a></td>
<td align="left">Exploratory Analysis of 16S-Based Microbiome Processed
Data</td>
<td align="center"><a
href="https://tmbuza.github.io/imap-data-exploration/">Link</a></td>
</tr>
</tbody>
</table>
</div>

# Machine Learning Rulegraph

![](dags/rulegraph.svg)


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
