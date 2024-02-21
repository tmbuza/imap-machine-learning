
# Install basic bookdown pkgs and automatically create a bib database
if (!require('base')) {
  install.packages('base', dependencies = TRUE)
}

if (!require('bookdown')) {
  install.packages('bookdown', dependencies = TRUE)
}

if (!require('knitr')) {
  install.packages('knitr', dependencies = TRUE)
}

if (!require('rmarkdown')) {
  install.packages('rmarkdown', dependencies = TRUE)
}


knitr::write_bib(c(.packages(), 'base','bookdown', 'knitr','rmarkdown'), 'library/packages.bib')

knitr::opts_chunk$set(
  echo  =TRUE,
  message  =FALSE,
  warning  =FALSE,
  cache  =FALSE,
  comment  =NA,
  collapse =TRUE,
  fig.path='./figures/',
  fig.show='asis',
  dev  ='png',
  fig.align='center',
  out.width  ="70%",
  fig.width  =7,
  fig.asp  =0.7,
  fig.show  ="asis"
)