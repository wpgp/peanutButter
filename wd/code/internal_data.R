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
country_info <- data.frame(country=country_list)
row.names(country_info) <- country_list

# default values spreadsheet
defaults <- read.csv('in/defaults.csv',stringsAsFactors=F)
row.names(defaults) <- defaults$country

# calculate country info
for(country in country_list){
  print(country)
    
  # load rasters
  buildings <- raster::raster(file.path(srcdir,paste0(country,'_buildings.tif')))
  urban <- raster::raster(file.path(srcdir,paste0(country,'_urban.tif')))
  
  # building counts
  country_info[country,'bld_count'] <- raster::cellStats(buildings, 'sum')
  country_info[country,'urb_count'] <- sum(buildings[urban==1], na.rm=T)
  country_info[country,'rur_count'] <- country_info[country,'bld_count'] - country_info[country,'urb_count']
  
  # default settings
  if(country %in% defaults$country){
    i <- country
  } else {
    i <- 'DEF'
  }
  for(parm in c('people_urb','units_urb','residential_urb','people_rur','units_rur','residential_rur')){
    country_info[i,parm] <- defaults[i,parm]      
  }
}
country_info <- country_info[order(country_info$country),]

# save as internal R package file
setwd('C:/RESEARCH/git/wpgp/peanutButter')
usethis::use_data(country_info, internal=T, overwrite=F)
