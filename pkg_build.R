# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# rebuild documentation
if(T){
  
  # render repository readme to html
  rmarkdown::render(input = 'README.md', 
                    output_format = 'html_document')
  
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
install.packages(getwd(), repo=NULL, type='source', lib='c:/research/r/library')

# load
library(peanutButter, lib='c:/research/r/library')

citation('peanutButter')

# run app
srcdir <- 'E:/worldpop/Projects/WP519893101_Polio/Working/git/peanutButter'
peanutButter::jelly(srcdir)
