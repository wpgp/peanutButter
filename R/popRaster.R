#' popRaster
#' @description Create population raster using the peanut butter method.
#' @param buildings_path Path to a raster (.tif) with building counts per pixel
#' @param urban_path Path to a raster (.tif) with binary map of urban areas (i.e. 0 and 1) 
#' @param people_urb Average number of people per housing unit
#' @param units_urb Average number of housing units per building
#' @param prob_urb Probability of residential building
#' @param people_rur Average number of people per housing unit
#' @param units_rur Average number of housing units per building
#' @param prob_rur Probability of residential building
#' @export

popRaster <- function(buildings_path, urban_path, 
                      people_urb=5, units_urb=1, prob_urb=0.5, 
                      people_rur=5, prob_rur=0.5, units_rur=1){
  
  # load rasters
  buildings <- raster::raster(buildings_path)
  urban <- raster::raster(urban_path)
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