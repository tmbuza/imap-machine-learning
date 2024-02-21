#!/bin/bash

# Generate interactive html report
snakemake --report report.html

hti -H report.html -o images/smkreport

