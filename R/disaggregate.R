#' Disaggregate population totals from polygons
#' @description Create gridded population estimates by disaggregating population totals from polygon geometries using building footprints.
#' @param feature An "sf" object with feature geometries (POLYGONS or MULTIPOLYGONS). The first column should contain population totals for each polygon (class "numeric").
#' @param buildings A "raster" object with counts of buildings per pixel.
#' @return Gridded population estimates as a "raster" object.

disaggregate <- function(feature, buildings, popcol=NULL){
  
  if(is.null(popcol)) popcol <- names(feature)[1]

  if(!is.numeric(sf::st_drop_geometry(feature)[,popcol])){
    stop('Column with population data ("popcol" or column #1) must be numeric',call. = FALSE)
  }
  if(length(grep('+proj=longlat +datum=WGS84', crs(feature), fixed=T)) == 0){
    stop('Polygons CRS proj4 string must include: +proj=longlat +datum=WGS84',call. = FALSE)
  }
  if(extent(feature)[1] < extent(buildings)[1]|extent(feature)[3] < extent(buildings)[3]|extent(feature)[2] > extent(buildings)[2]|extent(feature)[4] > extent(buildings)[4]){
    stop(paste('Polygons extent exceeds extent of building counts data which is: xmin=',extent(buildings)[1],'; xmax=',extent(buildings)[2],'; ymin=',extent(buildings)[3],'; ymax=',extent(buildings)[4],', in WGS84 projection. Suggest cropping polygons (geojson) extent',sep=''),call. = FALSE)
  }
  
  # id
  feature$id <- 1:nrow(feature)
  fcount <- length(feature$id)
  
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
  
  if(!fcount == length(bldgzonal[,'id'])){
    diff <- fcount - length(bldgzonal[,'id'])
    warning(paste(diff, 'polygon(s) did not cover any grid cells. Population counts of such polygons are not included in the output and the output total population may differ to the total population across input polygons'), call.=FALSE)
  }
  
  if(0 %in% bldgzonal[,'buildings']){
    warning('At least one polygon contains 0 buildings. Population counts of such polygons are not included in the output and the output total population may differ to the total population across input polygons', call.=FALSE) 
  }
    
  # population
  return(ppb * buildings)
  
}