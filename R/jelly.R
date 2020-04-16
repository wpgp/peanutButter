#' Run the peanutButter::jelly shiny application
#' @description A shiny web application to produce population estimates from building footprints using the peanut butter method.
#' @param srcdir Source directory path.
#' @export

jelly <- function(srcdir){
  
  .GlobalEnv$srcdir <- srcdir
  
  shiny::shinyAppDir(system.file('jelly', package='peanutButter'),
                     option = list(launch.browser=T))
}