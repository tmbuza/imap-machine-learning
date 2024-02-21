import os
import glob
import csv
import pandas as pd


ACCESSIONS=pd.read_csv("config/samples.tsv", sep="\t").loc[0:3]['sample_name']
print(ACCESSIONS)

SAMPLES=pd.read_csv("config/samples.tsv", sep="\t").loc[0:3]['sample_name'].tolist()
print(SAMPLES)

UNITS=pd.read_csv("config/units.tsv", sep="\t").loc[0:3]['sample_name'].tolist()
print(UNITS)
