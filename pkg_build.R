# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# package documentation
devtools::document()

# vignettes
devtools::build_vignettes()

# about jelly
file.copy('doc/jelly.html','inst/jelly/www/about.html', overwrite=T)

# install package
install.packages(getwd(), repo=NULL, type='source')

library(peanutButter)
peanutButter::jelly()
