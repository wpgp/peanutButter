# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);.libPaths('c:/research/r/library')

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path), '..'))

buildings <- raster::raster('//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter/SLE_buildings_v1_0_count.tif')

# load boundaries
feature <- sf::st_read('//worldpop.files.soton.ac.uk/worldpop/Personal/drl1u18/working/SLE/wd/in/National EAS/National__EAS.shp')

# area of polygons
feature$area <- sf::st_area(feature)

# population density
feature$density <- feature$TOTAL / feature$area

# gridded
pop <- disaggregate(buildings, feature, 'TOTAL')
