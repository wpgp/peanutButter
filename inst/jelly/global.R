# source directory
srcdir <- .GlobalEnv$srcdir

# data readme
lf <- list.files(srcdir)
if(any(grepl('README', lf))){
  path_readme <- file.path(srcdir, lf[grepl('README', lf)][1])
} else {
  path_readme <- NULL
}

# country info
country_info <- peanutButter:::country_info

# cleanup
lf1 <- list.files(tempdir(), recursive=T, full.names=T)
onStop(function(){
  lf2 <- list.files(tempdir(), recursive=T, full.names=T)
  unlink(lf2[!lf2 %in% lf1])
})
