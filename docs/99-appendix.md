# (APPENDIX) APPENDIX {-}

# IMAP GitHub Repos

<div class="tmbinfo">
<table>
<colgroup>
<col width="32%" />
<col width="46%" />
<col width="20%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Repo</th>
<th>Description</th>
<th align="right">Status</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><a
href="https://github.com/datainsights/imap-project-overview/">IMAP-OVERVIEW</a></td>
<td>IMAP project overview</td>
<td align="right"><a
href="https://datainsights.github.io/imap-project-overview/">In-progress</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-software-requirements/">IMAP-PART
01</a></td>
<td>Software requirement for microbiome data analysis with Snakemake
workflows</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-software-requirements/">In-progress</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-sample-metadata/">IMAP-PART
02</a></td>
<td>Downloading and exploring microbiome sample metadata from SRA
Database</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-sample-metadata/">In-progress</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-download-sra-reads/">IMAP-PART
03</a></td>
<td>Downloading and filtering microbiome sequencing data from SRA
database</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-download-sra-reads/">In-progress</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-read-quality-control/">IMAP-PART
04</a></td>
<td>Quality Control of Microbiome Next Generation Sequencing Reads</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-read-quality-control/">In-progress</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-bioinformatics-mothur/">IMAP-PART
05</a></td>
<td>Microbial profiling using MOTHUR and Snakemake workflows</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-bioinformatics-mothur/">In-progress</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-bioinformatics-qiime2/">IMAP-PART
06</a></td>
<td>Microbial profiling using QIIME2 and Snakemake workflows</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-bioinformatics-qiime2/">In-progress</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-data-processing/">IMAP-PART
07</a></td>
<td>Processing Output from 16S-Based microbiome bioinformatics
pipelines</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-data-processing/">In-progress</a></td>
</tr>
<tr class="odd">
<td align="left"><a
href="https://github.com/tmbuza/imap-exploratory-analysis/">IMAP-PART
08</a></td>
<td>Exploratory Analysis of 16S-Based Microbiome Processed Data</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-exploratory-analysis/">In-progress</a></td>
</tr>
<tr class="even">
<td align="left"><a
href="https://github.com/tmbuza/imap-snakemake-workflows/">IMAP-SUMMARY</a></td>
<td>Summary of snakemake workflows for microbiome data analysis</td>
<td align="right"><a
href="https://tmbuza.github.io/imap-snakemake-workflows/">In-progress</a></td>
</tr>
</tbody>
</table>
</div>

# Statistical Analysis Rulegraph

![](dags/rulegraph.svg)


# Session Information

Reproducibility relies on the ability to precisely recreate the working environment, and session information serves as a vital reference to achieve this consistency. Here we record details about the R environment, package versions, and system settings of the computing environment at the time of analysis. 


```r
library(knitr)
library(sessioninfo)

# Get session info
info <- capture.output(print(session_info()))

# Create the 'resources' folder if it doesn't exist
if (!dir.exists("resources")) {
  dir.create("resources")
}

# Save the session information to a text file without line numbers
cat(info, file = "r_session_info.txt", sep = "\n")
```





