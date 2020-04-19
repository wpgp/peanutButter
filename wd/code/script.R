# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# packages
library(tmap)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'

# run app
peanutButter::jelly(srcdir)

# load data
urban <- raster::raster(file.path(srcdir,'GHA_urban.tif'))

plot(urban, col=c('green','red'))

tm_shape(tmaptools::read_osm(urban)) + 
  
  tm_rgb()

tm_shape(urban) + 
  
  tm_raster(style = "cat", 
            n = 2, 
            title = "Settlement Type",
            palette = c("darkolivegreen4","red"))
