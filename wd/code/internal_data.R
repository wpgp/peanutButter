# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/sansModel'
srcdir <- 'in'

# country list
files <- list.files(srcdir)
country_list <- c()
for(i in 1:length(files)){
  country_list[i] <- unlist(strsplit(x = files[i], 
                                     split = '_'))[1]
}  
country_list <- sort(unique(country_list))

# check files exist
for(country in country_list){
  count.exists <- file.exists(file.path(srcdir,paste0(country,'_buildings.tif')))
  type.exists <- file.exists(file.path(srcdir,paste0(country,'_urban.tif')))
  
  # drop country if missing files
  if(!count.exists | !type.exists){
    country_list <- country_list[-which(country_list==country)]
  }
}

# setup country info data frame
country_info <- data.frame(country=country_list, 
                           bld_count=NA, urb_count=NA, rur_count=NA)
row.names(country_info) <- country_list

# calculate country info
for(country in country_list){
  print(country)
    
  # load rasters
  buildings <- raster::raster(file.path(srcdir,paste0(country,'_buildings.tif')))
  urban <- raster::raster(file.path(srcdir,paste0(country,'_urban.tif')))
  
  # total building count
  country_info[country,'bld_count'] <- raster::cellStats(buildings, 'sum')
  
  # urban building count
  country_info[country,'urb_count'] <- sum(buildings[urban==1], na.rm=T)
  
  # rural building count
  country_info[country,'rur_count'] <- country_info[country,'bld_count'] - country_info[country,'urb_count']
}

# save as internal R package file
usethis::use_data(country_info, internal=T, overwrite=T)
