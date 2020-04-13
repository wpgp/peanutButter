# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

## BUILD PACKAGE

# package documentation
devtools::document()

# vignettes
devtools::build_vignettes()

# about tab for peanutButter::jelly
file.copy('doc/jelly.html','inst/jelly/www/about.html', overwrite=T)

## INSTALL PACKAGE

# install from source
install.packages(getwd(), repo=NULL, type='source')

# load
library(peanutButter)

# run app
peanutButter::jelly()
