# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# package
library(peanutButter, lib='c:/research/r/library')
library(wopr, lib='c:/research/r/library')
library(data.table)

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'
srcdir <- 'e:/peanutButter'

# country list
files <- list.files(srcdir)
country_list <- c()
for(i in 1:length(files)){
  country_list[i] <- unlist(strsplit(x = files[i], 
                                     split = '_'))[1]
}  
# country_list <- sort(unique(c(country_list,as.character(peanutButter:::country_info$country))))
country_list <- sort(unique(country_list))

country_list <- unique(country_list[-which(country_list %in% c('XXX','Thumbs.db','checks','bf'))])

# default settings
defaults <- read.csv('data-raw/defaults.csv',stringsAsFactors=F)
row.names(defaults) <- defaults$country

# function to get source file names
fileNames <- function(country, path=srcdir){
  i <- list.files(path)
  i <- i[grepl(paste0(country,'_'), i)]
  count_file <- ifelse(any(grepl('_count.tif', i)), i[grepl('_count.tif', i)], NA)
  area_file <- ifelse(any(grepl('_total_area.tif', i)), i[grepl('_total_area.tif', i)], NA)
  urban_file <- ifelse(any(grepl('_urban.tif', i)), i[grepl('_urban.tif', i)], NA)
  year_file <- ifelse(any(grepl('_imagery_year.tif', i)), i[grepl('_imagery_year.tif', i)], NA)
  regions_file <- ifelse(any(grepl('_regions.tif', i)), i[grepl('_regions.tif', i)], NA)
  agesex_file <- ifelse(any(grepl('_table.csv', i)), i[grepl('_table.csv', i)], NA)
  data_file <- ifelse(any(grepl('_dt_Shape_Area_Urb.rds', i)), i[grepl('_dt_Shape_Area_Urb.rds', i)], NA)
  
  if(any(is.na(i))){
    stop(paste0('Source files missing for ',country,': ',names(which(is.na(i)))))
  }
  
  return(list(count = count_file, 
              area = area_file,
              urban = urban_file,
              year = year_file,
              regions = regions_file,
              agesex = agesex_file,
              data = data_file))
}

# check files exist
for(country in country_list){
  type.exists <- fileNames(country)[['urban']] %in% files
  year.exists <- fileNames(country)[['year']] %in% files
  data.exists <- fileNames(country)[['data']] %in% files
  regions.exists <- fileNames(country)[['regions']] %in% files
  agesex.exists <- fileNames(country)[['agesex']] %in% files
  
  # drop country if missing files
  if(!all(type.exists, data.exists, regions.exists, agesex.exists)){
    country_list <- country_list[-which(country_list==country)]
  }
}

# setup country info data frame
country_info <- data.frame(country = as.character(country_list),
                           country_name = defaults[country_list,'country_name'],
                           population = defaults[country_list,'population'])
row.names(country_info) <- country_list
country_info[,c('bld_count','urb_count','rur_count','bld_area','urb_area','rur_area','year2019','year2018','year2017','year2016','year2015pre')] <- NA

# refresh_countries <- c()
# 
# i <- peanutButter:::country_info
# if(length(refresh_countries) > 0) {
#   i <- i[-which(row.names(i) %in% refresh_countries),]
# }
# country_info[row.names(i),names(i)[-1]] <- i[,-1]

## calculate country info

# building counts
for(country in country_list){
  
  cat(paste0(country,', '))
  
  if(any(is.na(country_info[country,c('bld_count','urb_count','rur_count','bld_area','urb_area','rur_area')]))){
    
    # load data
    dat <- readRDS(file.path(srcdir,fileNames(country)[['data']]))
    urban <- raster::raster(file.path(srcdir,fileNames(country)[['urban']]))
    
    # building counts
    if(any(is.na(country_info[country,c('bld_count','urb_count','rur_count')]))){
      country_info[country,'bld_count'] <- nrow(dat)
      country_info[country,'urb_count'] <- sum(dat$bld_urban)
      country_info[country,'rur_count'] <- nrow(dat) - country_info[country,'urb_count']
    }
    if(any(is.na(country_info[country,c('bld_area','urb_area','rur_area')]))){
      country_info[country,'bld_area'] <- sum(dat$barea) * 0.0001
      country_info[country,'urb_area'] <- sum(dat[bld_urban==1]$barea) * 0.0001
      country_info[country,'rur_area'] <- sum(dat[bld_urban==0]$barea) * 0.0001
    }
  }
  if(any(is.na(country_info[country,c('year2019','year2018','year2017','year2016','year2015pre')]))){
    
    year <- raster::raster(file.path(srcdir, fileNames(country)[['year']]))
    
    pixel_count <- sum(!is.na(year[]))
    
    country_info[country,'year2019'] <- sum(year[]==2019, na.rm=T) / pixel_count
    country_info[country,'year2018'] <- sum(year[]==2018, na.rm=T) / pixel_count
    country_info[country,'year2017'] <- sum(year[]==2017, na.rm=T) / pixel_count
    country_info[country,'year2016'] <- sum(year[]==2016, na.rm=T) / pixel_count
    country_info[country,'year2015pre'] <- sum(year[]<=2015, na.rm=T) / pixel_count
  }
}

# default settings
for(country in country_list){
  i <- ifelse(country %in% defaults$country, country, 'DEF')
  for(parm in c('people_urb','units_urb','residential_urb','people_rur','units_rur','residential_rur')){
    country_info[country,parm] <- defaults[i,parm]      
  }
  country_info[country,c('residential_urb','residential_rur')] <- with(country_info[country,], min(1,defaults[country,'population'] / (urb_count*units_urb*people_urb + rur_count*units_rur*people_rur)))
  country_info[country,c('density_urb')] <- with(country_info[country,], (urb_count*people_urb*units_urb*residential_urb) / urb_area)
  country_info[country,c('density_rur')] <- with(country_info[country,], (rur_count*people_rur*units_rur*residential_rur) / rur_area)
}

# wopr
country_info$wopr <- country_info$country %in% unique(subset(wopr::getCatalogue(), category=='Population')[,'country'])
country_info$woprVision <- country_info$country %in% unique(wopr::getCatalogue(spatial_query=T)$country)

country_info$partial_footprints <- country_info$country %in% c()

# save as internal R package file
usethis::use_data(country_info, internal=T, overwrite=F)
