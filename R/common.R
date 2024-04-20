# Seed
set.seed(2022)

## Create most common Project Folder
if (!dir.exists("library")) {dir.create("library")}
if (!dir.exists("global")) {dir.create("global")}
if (!dir.exists("images")) {dir.create("images")}
if (!dir.exists("img")) {dir.create("img")}
if (!dir.exists("css")) {dir.create("css")}
if (!dir.exists("RDataRDS")) {dir.create("RDataRDS")}
if (!dir.exists("data")) {dir.create("data")}
if (!dir.exists("figures")) {dir.create("figures")}
if (!dir.exists("gifs")) {dir.create("gifs")}

knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  cache = FALSE,
  comment = NA,
  fig.path='./figures/',
  fig.show='asis',
  dev = 'png',
  fig.align='center',
  out.width = "70%",
  fig.width = 7,
  fig.asp = 0.7,
  fig.show = "asis"
)

options(knitr.graphics.auto_pdf = TRUE)

zeros <- function(x) sum(x == 0)
nonzeros <- function(x) sum(x != 0)

if(!require("tidyverse")) {install.packages("tidyverse")}
library(tidyverse, suppressPackageStartupMessages())

if(!require("knitr")) {install.packages("knitr")}
library(knitr)

if(!require("rmarkdown")) {install.packages("rmarkdown")}
library(rmarkdown)

if(!require("bookdown")) {install.packages("bookdown")}
library(bookdown)

if(!require("ggpubr")) {install.packages("ggpubr")}
library(ggpubr)

if(!require("downlit")) {install.packages("downlit")}
library(downlit)

if(!require("ggtext")) {install.packages("ggtext")}
library(ggtext)

if(!require("dendextend")) {install.packages("dendextend")}
library(dendextend)
#
# if(!require("metagMisc")) {devtools::install_github("vmikk/metagMisc")}
# library(metagMisc)

if(!require("cgwtools")) {install.packages("cgwtools")}
library(cgwtools)

if(!require("gifski")) {install.packages("gifski")}
library(gifski)

# if(!require("robCompositions")) {install.packages("robCompositions")}
# library(robCompositions)
#
# if(!require("microbiome")) {install.packages("microbiome")}
# library(microbiome)

if(!require("scales")) {install.packages("scales")}
library(scales)

if(!require("DiagrammeR")) {install.packages("DiagrammeR")}
library(DiagrammeR)

if(!require("DiagrammeRsvg")) {install.packages("DiagrammeRsvg")}
library(DiagrammeRsvg)
#
# if(!require("")) {install.packages("")}
# library()
#
# if(!require("")) {install.packages("")}
# library()
#
# if(!require("")) {install.packages("")}
# library()

# library(caret); packageVersion("caret")
# # library(vegan); packageVersion("vegan")
# # library(ape); packageVersion("ape")
# # library(ggplot2); packageVersion("ggplot2")
# # library(microbiome); packageVersion("microbiome")
# if(!require("robCompositions")) {install.packages("robCompositions")}
# # library(robCompositions); packageVersion("robCompositions")
# # library(reshape2); packageVersion("reshape2")
# library(scales); packageVersion("scales")
# # library(funModeling); packageVersion("funModeling")
# # library(purrr); packageVersion("purrr")
# # library(phyloseq)
# # library(gganimate)
# # library(gifski)
# library(cgwtools)
# # library(dendextend)
#
#

#
# if(!require("microViz")) {devtools::install_github("david-barnett/microViz")}
# library(microViz)
#
# if(!require("metamicrobiomeR")) {devtools::install_github("nhanhocu/metamicrobiomeR")}
# library(metamicrobiomeR)
#
# if(!require("corncob")) {install.packages("corncob")}
# library(corncob)
#
# # if (!require("BiocManager", quietly = TRUE)) {install.packages("BiocManager")}
# # BiocManager::install("ggtree")
# # library(ggtree)

if(!require("conflicted")) {install.packages("conflicted")}
library(conflicted)

# conflict_prefer("filter", "dplyr", "base")
# conflict_prefer("select", "dplyr", "base")
# conflict_prefer("transpose", "data.table", "purr")
# conflict_prefer("transpose", "purr", "data.table")
#
conflict_prefer("!", "cgwtools")
conflict_prefer("!", "base")

# theme_set(theme_bw())
#
# axislayout <- theme(axis.text.x = element_text(size=12,angle = 90, hjust = 0)) +
#   theme(axis.text.y = element_text(size=12))+
#   theme(axis.title=element_text(size=14,face="bold"))
#
#
# Italicize Axes Texts
# # Single parenthesis in regexp means save the contents of what is matched in the parenthesis
# # \\s match pattern with space.
# # \\S match pattern without space.
# # ^(\\S)$ match pattern without space at the beginning through the end

# Formatting
plainbar_fmt <- theme(
  axis.text.x=element_blank(),
  axis.title.x=element_blank(),
  axis.title.y=element_blank(),
  legend.position="none",
  plot.title = element_text(hjust = 0.5),
  plot.subtitle = element_text(hjust = 0.5),
  axis.title=element_text(size=14,face="bold"))


nowhitespace <- scale_y_continuous(expand = c(0, 0))

italicize_w_md <- function(x) {
  mutate(x = str_replace(x,
                         "(.*)_unclassified", "Unclassified *\\1*"),
         x = str_replace(x,
                         "^(\\S*)$", "\\1*"))
}

italic = theme(axis.text = element_text(face = "italic", size = 12))
xitalic = theme(axis.text.x = element_text(face = "italic", size = 12))
yitalic = theme(axis.text.y = element_text(face = "italic", size = 12))

## Axes
noxticks <- theme(axis.text.x=element_blank())
noxlabels <- theme(axis.text.x=element_blank())
noxtitle <- theme(axis.title.x=element_blank())
noyticks <- theme(axis.text.y=element_blank())
noylabels <- theme(axis.text.y=element_blank())
noytitle <- theme(axis.title.y=element_blank())

# Legend Text size
legend12 <- theme(legend.text=element_text(size=12))
legend10 <- theme(legend.text=element_text(size=10))
legend8 <- theme(legend.text=element_text(size=8))
legend6 <- theme(legend.text=element_text(size=6))
legend4 <- theme(legend.text=element_text(size=4))

# Legend position
rightlegend <- theme(legend.position="right")
bottomlegend <- theme(legend.position="bottom")
leftlegend <- theme(legend.position="left")
nolegend <- theme(legend.position="none")

# Center Plot title
centertitle <- theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.subtitle = element_text(hjust = 0.5))

formatPlot <-
  theme(strip.text.x = element_text(size = 16))+
  theme(plot.title = element_text(size = 16, face = "bold")) +
  theme(plot.subtitle = element_text(size = 14)) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(axis.text = element_text(hjust = 1, size = 10))+
  theme(axis.title=element_text(size=14,face="bold")) +
  theme(axis.text.x = element_text(hjust=0.5))

axislabel14bold <- theme(axis.title=element_text(size=14,face="bold"))

# Continuous values
xbreaks5 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=5))
xbreaks10 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=10))
xbreaks15 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=15))

ybreaks5 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=5))
ybreaks10 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=10))
ybreaks15 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=15))

## Discrete values
xbreaksdis5 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=5))
xbreaksdis10 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=10))
xbreaksdis15 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=15))

ybreaksdis5 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=5))
ybreaksdis10 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=10))
ybreaksdis15 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=15))

facetsize14 <- theme(strip.text.x = element_text(size = 14, colour = "black", angle = 0))
facetsize12 <- theme(strip.text.x = element_text(size = 12, colour = "black", angle = 0))
facetsize10 <- theme(strip.text.x = element_text(size = 10, colour = "black", angle = 0))
facetsize8 <- theme(strip.text.x = element_text(size = 8, colour = "black", angle = 0))

axislayout <- theme(axis.text.x = element_text(size=12,angle = 90, hjust = 0)) +
  theme(axis.text.y = element_text(size=12))+
  theme(axis.title=element_text(size=14,face="bold"))

mediumaxislayout <- theme(axis.text.x = element_text(size=10,angle = 0, hjust = 0)) +
  theme(axis.text.y = element_text(size=10))+
  theme(axis.title=element_text(size=14,face="bold"))

mediumaxislayout2 <- theme(axis.text.x = element_text(size=10,angle = 90, hjust = 1)) +
  theme(axis.text.y = element_text(size=10))+
  theme(axis.title=element_text(size=12,face="bold"))

mediumaxislayout3 <- theme(axis.text.x = element_text(size=10,angle = 0, hjust = 0)) +
  theme(axis.text.y = element_text(size=10))+
  theme(axis.title=element_text(size=12,face="bold"))

smallaxislayout <- theme(axis.text.x = element_text(size=8,angle = 90, hjust = 0)) +
  theme(axis.text.y = element_text(size=10))+
  theme(axis.title=element_text(size=12,face="bold"))

smallaxislayout2 <- theme(axis.text.x = element_text(size=8,angle = 90, hjust = 1)) +
  theme(axis.text.y = element_text(size=8))+
  theme(axis.title=element_text(size=10,face="bold"))

manysampleslayout <- theme(axis.text.x = element_text(size=6,angle = 90, hjust = 0)) +
  theme(axis.text.y = element_text(size=6))+
  theme(axis.title=element_text(size=10,face="bold"))

normalaxislayout <- theme(axis.text.x = element_text(size=12,angle = 0, hjust = 0)) +
  theme(axis.text.y = element_text(size=12))+ theme(axis.title=element_text(size=14,face="bold"))

normalaxislayout2 <- theme(axis.text.x = element_text(size=8,angle = 90, hjust = 0)) +
  theme(axis.text.y = element_text(size=10))+ theme(axis.title=element_text(size=12,face="bold"))

normalaxislayout3 <- theme(axis.text.x = element_text(size=10,angle = 0, hjust = 0)) +
  theme(axis.text.y = element_text(size=10))+ theme(axis.title=element_text(size=12))

formatPlot <- theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.subtitle = element_text(hjust = 0.5)) +
  theme(axis.text = element_text(hjust = 1, size = 8))+
  theme(axis.title=element_text(size=10,face="bold")) +
  theme(plot.title = element_text(size = 10, face = "bold")) +
  theme(axis.text.x = element_text(hjust=0.5))

formatPlot2 <-
  theme(plot.title = element_text(size = 16, face = "bold")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.subtitle = element_text(hjust = 0.5)) +
  theme(axis.text = element_text(hjust = 1, size = 12))+
  theme(axis.title=element_text(size=14,face="bold")) +
  theme(axis.text.x = element_text(hjust=0.5))
