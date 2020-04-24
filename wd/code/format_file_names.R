# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);.libPaths('c:/research/r/library')

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'

# working directory
setwd(srcdir)

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
  count.exists <- paste0(country,'_buildings.tif') %in% files
  type.exists <- paste0(country,'_urban.tif') %in% files
  
  # drop country if missing files
  if(!count.exists | !type.exists){
    country_list <- country_list[-which(country_list==country)]
  }
}

# rename files to directories
for(country in country_list){
  file.rename(from = paste0(country,'_buildings.tif'),
              to = paste0(country,'_buildings_v1_0_count.tif'))
  file.rename(from = paste0(country,'_urban.tif'),
              to = paste0(country,'_buildings_v1_0_urban.tif'))
}
