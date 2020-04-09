# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# package documentation
devtools::document()

# # vignettes
# devtools::build_vignettes('pkg')

# render peanutButter README to HTML
rmarkdown::render(input='README.md',
                  output_format=c('html_document'),
                  output_file='README.html',
                  output_dir=getwd())

# about jelly
file.copy('README.html','inst/jelly/www/about.html', overwrite=T)

# install package
install.packages(getwd(), repo=NULL, type='source')

library(peanutButter)
