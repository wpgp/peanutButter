# source directory
srcdir <- .GlobalEnv$srcdir
srcfiles <- list.files(srcdir)

# country info
country_info <- peanutButter:::country_info
initialize_country <- sample(country_info$country[!country_info$wopr & !country_info$woprVision],1)

# maximum file upload size
options(shiny.maxRequestSize = 50*1024^2)

# function to get source file names
fileNames <- function(country, path=srcdir){
  i <- list.files(path)
  i <- i[grepl(paste0(country,'_'), i)]
  count_file <- ifelse(any(grepl('_count.tif', i)), i[grepl('_count.tif', i)], NA)
  urban_file <- ifelse(any(grepl('_urban.tif', i)), i[grepl('_urban.tif', i)], NA)
  regions_file <- ifelse(any(grepl('_regions.tif', i)), i[grepl('_regions.tif', i)], NA)
  agesex_file <- ifelse(any(grepl('_table.csv', i)), i[grepl('_table.csv', i)], NA)
  
  if(any(is.na(i))){
    stop(paste0('Source files missing for ',country,': ',names(which(is.na(i)))))
  }
  
  return(list(count = count_file, 
              urban = urban_file,
              regions = regions_file,
              agesex = agesex_file))
}

# cleanup
onStop(function(temp_onStart=list.files(tempdir(), recursive=T, full.names=T)){
  temp_onStop <- list.files(tempdir(), recursive=T, full.names=T)
  unlink(temp_onStop[!temp_onStop %in% temp_onStart])
})
