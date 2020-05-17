# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# rebuild documentation
if(T){
  # package documentation
  devtools::document()
  
  # vignettes
  devtools::build_vignettes()
  
  # about tab for peanutButter::jelly
  file.copy('doc/jelly.html','inst/jelly/www/about.html', overwrite=T)
}

# install from source
install.packages(getwd(), repo=NULL, type='source', lib='c:/research/r/library')
citation('peanutButter')

# load
library(peanutButter, lib='c:/research/r/library')

# run app
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'
peanutButter::jelly(srcdir)
