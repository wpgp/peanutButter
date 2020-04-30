# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);.libPaths('c:/research/r/library')

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path), '..'))

buildings <- raster::raster('//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter/SLE_buildings_v1_0_count.tif')

# load boundaries
feature <- sf::st_read('//worldpop.files.soton.ac.uk/worldpop/Personal/drl1u18/working/SLE/wd/in/National EAS/National__EAS.shp')
feature <- sf::st_read('//worldpop.files.soton.ac.uk/worldpop/Personal/drl1u18/working/SLE/wd/in/Sections_GriddedCensus/SLE_sections_harmonized.shp')

# area of polygons
feature$area <- sf::st_area(feature)

# population density
feature$density <- feature$SUM_TOTAL / feature$area

feature <- feature[,c('SUM_TOTAL', names(feature)[-which(names(feature)=='SUM_TOTAL')])]
feature <- sf::st_transform(feature, crs=4326)
st_write(feature, 'wd/out/SLE.geojson', append=F)


# gridded
t1 <- Sys.time()
pop <- disaggregate(feature, 'TOTAL', buildings)
difftime(Sys.time(), t1)
