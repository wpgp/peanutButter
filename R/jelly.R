#' Run the peanutButter::jelly shiny application
#' @description A shiny web application to produce population estimates from building footprints using the peanut butter method.
#' @export

jelly <- function(){
  shiny::shinyAppDir(system.file('jelly', package='peanutButter'),
                     option = list(launch.browser=T))
}