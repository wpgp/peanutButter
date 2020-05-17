# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# packages
library(peanutButter, lib='c:/research/r/library')

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'

# load inputs
country <- 'ZMB'

buildings <- raster::raster(file.path(srcdir, paste0(country,'_buildings_v1_0_count.tif')))
urban <- raster::raster(file.path(srcdir, paste0(country,'_buildings_v1_0_urban.tif')))
agesex_regions <- raster::raster(file.path(srcdir, paste0(country,'_agesex_regions.tif')))
agesex_table <- read.csv(file.path(srcdir, paste0(country,'_agesex_table.csv')))

agesex_table <- agesex_table[,c('id',
                                names(agesex_table)[grepl('m_',names(agesex_table))],
                                names(agesex_table)[grepl('f_',names(agesex_table))])]


# peanutButter pop raster
pop_raster <- aggregate(buildings, urban)

# agesex function
agesex_raster <- agesex(agesex_select = c('f_0','f_1','m_0','m_1'), 
                        pop_raster = pop_raster,
                        agesex_regions = agesex_regions,
                        agesex_table = agesex_table)

