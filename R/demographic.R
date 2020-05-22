#' Create population grid for age-sex groups
#' @description Create gridded population estimates for specific age-sex groups by disaggregating population totals using gridded age-sex proportions.
#' @param population raster. Gridded population estimates.
#' @param group_select character vector. Vector of age-sex groups to include in the population estimate (i.e. "f0" = females less than 1 year, "f1" = females 1 to 4 years, "f5" = females 5 to 9 years, etc.; c("m0","m1","f0","f1") = children under five)
#' @param regions raster. Raster of region IDs for age-sex information.
#' @param proportions data.frame. Proportion of the population in each age-sex group in each region. The first column must contain region IDs that correspond to "regions". The remaining columns are named in accordance with "group_select".
#' @return raster. Gridded population estimates.
#' @export

demographic <- function(population, group_select, regions, proportions){
  
  # format proportions
  names(proportions)[1] <- 'id'
  row.names(proportions) <- proportions$id
  
  # sum proportions
  if(length(group_select)==1){
    proportions$prop <- proportions[,group_select]
  } else {
    proportions$prop <- apply(proportions[,group_select], 1, sum, na.rm=T)
  }
  
  # reduce cols
  proportions <- proportions[,c(1,ncol(proportions))]
  
  # save raster coordinate system
  crs1 <- raster::crs(regions)
  ex1 <- raster::xmin(regions)
  ex2 <- raster::xmax(regions)
  ex3 <- raster::ymin(regions)
  ex4 <- raster::ymax(regions)

  # raster to matrix
  regions <- raster::as.matrix(regions)

  # proportions to matrix
  group_proportion <- regions
  group_proportion[] <- NA
  for(id in proportions$id){
    group_proportion[which(regions==id)] <- proportions[as.character(id), 'prop']
  }

  # rasterize group proportions
  group_proportion <- raster::raster(group_proportion, crs=crs1, xmn=ex1, xmx=ex2, ymn=ex3, ymx=ex4)
  
  # calculate age-sex population
  group_population <- population * group_proportion
  
  return(group_population)
}