#' Disaggregate population totals from polygons
#' @description Create gridded population estimates by disaggregating population totals from polygon geometries using building footprints.
#' @param feature sf. An "sf" object with feature geometries (POLYGONS or MULTIPOLYGONS). The first column should contain population totals for each polygon (class "numeric").
#' @param buildings raster. A "raster" object with counts of buildings per pixel.
#' @param popcol character. The column name from "feature" that contains the population totals. If NULL, the first column will be used.
#' @return Gridded population estimates as a "raster" object.
#' @export

disaggregator <- function(feature, buildings, popcol=NULL){
  
  feature <- sf::st_transform(feature, crs=4326)
  
  if(is.null(popcol)) popcol <- names(feature)[1]

  if(!is.null(popcol) & !popcol %in% names(feature)){
    stop(paste(popcol,'is not a column name in the attribute table.'), call.=F)
  }
  
  if(!is.numeric(sf::st_drop_geometry(feature)[,popcol])){
    stop(paste0('Column with population data (',ifelse(is.null(popcol),'column #1',popcol),') must be numeric.'),call. = FALSE)
  }
  # if(length(grep('+proj=longlat +datum=WGS84', crs(feature), fixed=T)) == 0){
  #   stop('Polygons CRS proj4 string must include: +proj=longlat +datum=WGS84',call. = FALSE)
  # }
  
  pad <- 10 * 0.0008333333
  if(raster::extent(feature)[1] < (raster::extent(buildings)[1] - pad) | 
     raster::extent(feature)[3] < (raster::extent(buildings)[3] - pad) | 
     raster::extent(feature)[2] > (raster::extent(buildings)[2] + pad) | 
     raster::extent(feature)[4] > (raster::extent(buildings)[4] + pad) ){
    stop(paste('Polygons extent exceeds extent of building counts data which is',
               ': xmin=',raster::extent(buildings)[1],
               '; xmax=',raster::extent(buildings)[2],
               '; ymin=',raster::extent(buildings)[3],
               '; ymax=',raster::extent(buildings)[4],
               ', in WGS84 projection. Suggest cropping polygons (geojson) extent',sep=''),call. = FALSE)
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
    warning(paste(diff, 'polygon(s) did not cover any grid cells and were ignored. Output total population may differ from input total population among all polygons.'), call.=FALSE)
  }
  
  if(0 %in% bldgzonal[,'buildings']){
    warning('At least one polygon contains 0 buildings. Output total population for these grid cells will be NA.', call.=FALSE) 
  }
    
  # population
  return(ppb * buildings)
  
}