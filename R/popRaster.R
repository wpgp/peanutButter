#' popRaster
#' @description Create population raster for sansModel
#' @param country Country selection (ISO3)
#' @param srcdir Source directory
#' @param people_urb Average number of people per housing unit
#' @param units_urb Average number of housing units per building
#' @param prob_urb Probability of residential building
#' @param people_rur Average number of people per housing unit
#' @param units_rur Average number of housing units per building
#' @param prob_rur Probability of residential building
#' @export

popRaster <- function(country, srcdir, 
                      people_urb=5, units_urb=1, prob_urb=0.5, 
                      people_rur=5, prob_rur=0.5, units_rur=1){
  
  # load rasters
  buildings <- raster::raster(file.path(srcdir,paste0(country,'_buildings.tif')))
  urban <- raster::raster(file.path(srcdir,paste0(country,'_urban.tif')))
  pop_raster <- raster::raster(buildings)
  
  # vectorize rasters
  buildings <- buildings[]
  urban <- as.logical(urban[])
  rural <- !urban
  
  urban[is.na(urban)] <- F
  rural[is.na(rural)] <- F
  
  # rasterize urban population
  print('urban population...')
  pop_raster[urban] <- buildings[urban] * prob_urb * units_urb * people_urb
  
  # rasterize rural population
  print('rural population...')
  pop_raster[rural] <- buildings[rural] * prob_rur * units_rur * people_rur
  
  return(pop_raster)
}