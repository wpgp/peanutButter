# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# R library
lib <- NULL
try(suppressWarnings(source('wd/lib.r')), silent=T)
lib <- c(lib, .libPaths())

# rebuild documentation
if(T){
  
  # render README to markdown and html
  rmarkdown::render(input='README.rmd',
                    output_format=c('github_document'),
                    output_file='README.md',
                    output_dir=getwd())
  
  # package documentation
  devtools::document()
  
  # vignettes
  devtools::build_vignettes()
  
  # about tab for peanutButter::jelly
  file.copy('doc/jelly.html','inst/jelly/www/about.html', overwrite=T)
}

# restart R
rstudioapi::restartSession()

# install from source
install.packages(getwd(), repo=NULL, type='source', lib=lib)

# load
library(peanutButter, lib=lib)

citation('peanutButter')

# run app
srcdir <- 'E:/worldpop/Projects/WP519893101_Polio/Working/git/peanutButter'
peanutButter::jelly(srcdir)
