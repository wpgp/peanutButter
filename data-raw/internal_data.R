# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# package
library(peanutButter, lib='c:/research/r/library')

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'

# country list
files <- list.files(srcdir)
country_list <- c()
for(i in 1:length(files)){
  country_list[i] <- unlist(strsplit(x = files[i], 
                                     split = '_'))[1]
}  
# country_list <- sort(unique(c(country_list,as.character(peanutButter:::country_info$country))))
country_list <- sort(unique(country_list))
country_list <- country_list[-which(country_list %in% c('XXX'))]

# function to get file names
fileNames <- function(country, path=srcdir){
  i <- list.files(path)
  i <- i[grepl(paste0(country,'_'), i)]
  count_file <- ifelse(any(grepl('_count.tif', i)), i[grepl('_count.tif', i)], NA)
  urban_file <- ifelse(any(grepl('_urban.tif', i)), i[grepl('_urban.tif', i)], NA)
  regions_file <- ifelse(any(grepl('_regions.tif', i)), i[grepl('_regions.tif', i)], NA)
  agesex_file <- ifelse(any(grepl('_table.csv', i)), i[grepl('_table.csv', i)], NA)
  
  return(list(count = count_file, 
              urban = urban_file,
              regions = regions_file,
              agesex = agesex_file))
}

# check files exist
for(country in country_list){
  count.exists <- fileNames(country)[['count']] %in% files
  type.exists <- fileNames(country)[['urban']] %in% files
  
  # drop country if missing files
  if(!count.exists | !type.exists){
    country_list <- country_list[-which(country_list==country)]
  }
}

# setup country info data frame
country_info <- data.frame(country=as.character(country_list))
row.names(country_info) <- country_list

refresh_countries <- c()

i <- peanutButter:::country_info
if(length(refresh_countries) > 0) {
  i <- i[-which(row.names(i) %in% refresh_countries),]
}
country_info[row.names(i),names(i)[-1]] <- i[,-1]

## calculate country info

# building counts
for(country in country_list){
  if(is.na(country_info[country,'bld_count']) | is.na(country_info[country,'urb_count']) | is.na(country_info[country,'rur_count'])){
    print(country)
    
    # load rasters
    buildings <- raster::raster(file.path(srcdir,fileNames(country)[['count']]))
    urban <- raster::raster(file.path(srcdir,fileNames(country)[['urban']]))
    
    # building counts
    country_info[country,'bld_count'] <- raster::cellStats(buildings, 'sum')
    country_info[country,'urb_count'] <- sum(buildings[urban==1], na.rm=T)
    country_info[country,'rur_count'] <- country_info[country,'bld_count'] - country_info[country,'urb_count']
  }
}

# default settings
defaults <- read.csv('data-raw/defaults.csv',stringsAsFactors=F)
row.names(defaults) <- defaults$country

for(country in country_list){
  i <- ifelse(country %in% defaults$country, country, 'DEF')
  for(parm in c('people_urb','units_urb','residential_urb','people_rur','units_rur','residential_rur')){
    country_info[country,parm] <- defaults[i,parm]      
  }
  country_info[country,c('residential_urb','residential_rur')] <- min(1,defaults[country,'population'] / (country_info[country,'urb_count']*country_info[country,'units_urb']*country_info[country,'people_urb'] + country_info[country,'rur_count']*country_info[country,'units_rur']*country_info[country,'people_rur']))
}

# wopr
country_info$wopr <- country_info$country %in% unique(subset(wopr::getCatalogue(), category=='Population')[,'country'])
country_info$woprVision <- country_info$country %in% unique(wopr::getCatalogue(spatial_query=T)$country)

country_info$partial_footprints <- country_info$country %in% c()

# save as internal R package file
usethis::use_data(country_info, internal=T, overwrite=F)
