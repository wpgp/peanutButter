#' Create population grid for age-sex groups
#' @description Create gridded population estimates for specific age-sex groups by disaggregating population totals using gridded age-sex proportions.
#' @param agesex_select character vector. Vector of age-sex groups to include in the population estimate (e.g. c("m0","m1","f0","f1") = children under five; "f0" = females less than 1 year, "f1" = females 1 to 4 years, "f5" = females 5 to 9 years, etc.)
#' @param pop_raster raster. Gridded population estimates.
#' @param agesex_regions raster. Raster of region IDs for age-sex information.
#' @param agesex_table data.frame. Proportion of the population in each age-sex group in each region. The first column must contain region IDs that correspond to "agesex_regions". The remaining columns are named in accordance with "agesex_select".
#' @return raster. Gridded population estimates.

agesex <- function(agesex_select, pop_raster, agesex_regions, agesex_table){
  
  # format agesex_table
  names(agesex_table)[1] <- 'id'
  row.names(agesex_table) <- agesex_table$id
  
  # agesex_regions to matrix
  crs1 <- crs(agesex_regions)
  ex1 <- xmin(agesex_regions); ex2 <- xmax(agesex_regions); ex3 <- ymin(agesex_regions); ex4 <- ymax(agesex_regions)
  agesex_regions <- as.matrix(agesex_regions)
  
  # sum proportions
  agesex_table$prop <- apply(agesex_table[,agesex_select], 1, sum, na.rm=T)
  agesex_table <- agesex_table[,c(1,ncol(agesex_table))]
  
  # matrix of proportions
  agesex_props <- agesex_regions
  agesex_props[] <- NA
  for(id in agesex_table$id){
    agesex_props[which(agesex_regions==id)] <- agesex_table[as.character(id), 'prop']
  }
  
  # rasterize proportions
  agesex_props <- raster(agesex_props, crs=crs1, xmn=ex1, xmx=ex2, ymn=ex3, ymx=ex4)
  
  # calculate age-sex population
  agesex_pop <- pop_raster * agesex_props
  
  return(agesex_pop)
}