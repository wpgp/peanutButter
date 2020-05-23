# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# packages
library(peanutButter, lib='c:/research/r/library')

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'

# load inputs
country <- 'SSD'

buildings <- raster::raster(file.path(srcdir, paste0(country,'_buildings_v1_0_count.tif')))
urban <- raster::raster(file.path(srcdir, paste0(country,'_buildings_v1_0_urban.tif')))
regions <- raster::raster(file.path(srcdir, paste0(country,'_agesex_regions.tif')))
proportions <- read.csv(file.path(srcdir, paste0(country,'_agesex_table.csv')))

feature <- sf::st_read('c:/research/temp/SLE_harmonized_EA_totals.geojson')
  
# bottom-up population raster
population <- aggregator(buildings, urban)

# top-down population raster
population <- disaggregator(feature, buildings)

# demographic function
t1 <- Sys.time()
group_population <- demographic(population = population,
                                group_select = c('f0','m0'), 
                                regions = regions,
                                proportions = proportions)
difftime(Sys.time(), t1)

