#' Disaggregate population totals from polygons
#' @description Create gridded population estimates by disaggregating population totals from polygon geometries using building footprints.
#' @param feature An "sf" object with feature geometries (POLYGONS or MULTIPOLYGONS). The first column should contain population totals for each polygon (class "numeric").
#' @param buildings A "raster" object with counts of buildings per pixel.
#' @return Gridded population estimates as a "raster" object.

disaggregate <- function(buildings, feature, popcol=NULL){
  
  if(is.null(popcol)) popcol <- names(feature)[1]
  
  # id
  feature$id <- 1:nrow(feature)
  
  # raster of geographic units (feature)
  units <- fasterize::fasterize(feature, buildings, 'id')
  
  # building zonal sum
  bldgzonal <- raster::zonal(buildings, units, sum)
  colnames(bldgzonal) <- c('id','buildings')
  row.names(bldgzonal) <- bldgzonal[,'id']
  
  # building count to feature
  feature <- merge(feature, bldgzonal, 'id')
  
  # people per building
  feature$ppb <- sf::st_drop_geometry(feature)[,popcol] / sf::st_drop_geometry(feature)[,'buildings']
  
  # rasterize people per building
  ppb <- fasterize::fasterize(feature, buildings, 'ppb')
  
  # population
  return(ppb * buildings)
}