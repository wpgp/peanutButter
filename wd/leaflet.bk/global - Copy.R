library(leaflet)

srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/sansModel'

# country list
files <- list.files(srcdir)
country_list <- c()
for(i in 1:length(files)){
  country_list[i] <- unlist(strsplit(x = files[i], 
                                     split = '_'))[1]
}  
country_list <- sort(unique(country_list))

# color palette
pal <- wopr:::woprVision_global$pal
bins <- wopr:::woprVision_global$bins

