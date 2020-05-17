library(peanutButter)

# source directory
srcdir <- .GlobalEnv$srcdir

# data readme
data_version <- 'v1.0'

# country info
country_info <- peanutButter:::country_info
initialize_country <- sample(country_info$country[!country_info$wopr & !country_info$woprVision],1)

# maximum file upload size
options(shiny.maxRequestSize = 50*1024^2)

# cleanup
lf1 <- list.files(tempdir(), recursive=T, full.names=T)
onStop(function(){
  lf2 <- list.files(tempdir(), recursive=T, full.names=T)
  unlink(lf2[!lf2 %in% lf1])
})
