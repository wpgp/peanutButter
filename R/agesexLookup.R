#' Format shiny age-group selection for peanutButter
#' @param male logical.
#' @param female logical.
#' @param male_select character vector.
#' @param female_select character vector.
#' @export

agesexLookup <- function(male, female, male_select, female_select){
  mcols <- fcols <- NULL
  breaks <- c(0, 1, seq(5,80,by=5))
  labels <- c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+')
  
  if(male) {
    map <- setNames(paste0('m',breaks), labels)
    index <- sapply(male_select, function(y) which(map[y] == map))
    mcols <- as.character(map[min(index):max(index)])
  }
  if(female) {
    map <- setNames(paste0('f',breaks), labels)
    index <- sapply(female_select, function(y) which(map[y] == map))
    fcols <- as.character(map[min(index):max(index)])
  }
  return(c(mcols, fcols))
}



           


