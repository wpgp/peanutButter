# source directory
srcdir <- .GlobalEnv$srcdir

# country info
country_info <- peanutButter:::country_info

# cleanup
lf1 <- list.files(tempdir(), recursive=T, full.names=T)
onStop(function(){
  lf2 <- list.files(tempdir(), recursive=T, full.names=T)
  unlink(lf2[!lf2 %in% lf1])
})