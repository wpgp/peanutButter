#' Download source data from WOPR
#' @description Download peanutButter source data from the WorldPop Open Population Repository
#' @param version Version of the buildings data sets to use
#' @param wopr_dir Directory where downloads should be saved
#' @param maxsize Maximum file size (MB) allowed to download without notification
#' @return Files are downloaded to local disk
#' @export

downloadData <- function(version='v1.0', wopr_dir='wopr', maxsize=100){

  # get catalogue
  response <- httr::content( httr::GET('https://wopr.worldpop.org/api/v1.0/data'), as='parsed')
  
  cols <- c('country','category','version', 'filetype', names(response[[1]][[1]][[1]][[1]]))
  catalogue <- data.frame(matrix(NA, ncol=length(cols), nrow=0))
  names(catalogue) <- cols
  
  for(iso in names(response)){
    for(category in names(response[[iso]])){
      for(version in names(response[[iso]][[category]])){
        for(filetype in names(response[[iso]][[category]][[version]])){
          newrow <- data.frame(matrix(NA, ncol=length(cols), nrow=1))
          names(newrow) <- cols
          
          newrow[1,c('country','category','version','filetype')] <- c(iso, category, version, filetype)
          
          for(attribute in names(response[[iso]][[category]][[version]][[filetype]])){
            value <- response[[iso]][[category]][[version]][[filetype]][[attribute]]
            if(!is.null(value)){
              newrow[1, attribute] <- value  
            }
          }
          catalogue <- rbind(result, newrow)
        }
      }
    }
  }
  
  # subset catalogue
  dat <- subset(catalogue, country %in% peanutButter:::country_info$country &
                  category == 'buildings' &
                  version == version &
                  filetype %in% c('count','urban'))
  
  dat$category <- tolower(dat$category)
  
  tryCatch({
    for(i in 1:nrow(dat)){
      dir.create(wopr_dir, showWarnings=F)
      dir.create(file.path(wopr_dir,dat[i,'country']), showWarnings=F)
      dir.create(file.path(wopr_dir,dat[i,'country'], dat[i,'category']), showWarnings=F)
      dir.create(file.path(wopr_dir,dat[i,'country'], dat[i,'category'], dat[i,'version']), showWarnings=F)
      
      filepath <- file.path(wopr_dir, dat[i,'country'], dat[i,'category'], dat[i,'version'], dat[i,'file'])
      
      filematch <- dat[i,'hash']==tools::md5sum(filepath)
      
      if(!file.exists(filepath) | !filematch){
        
        # check file size
        fname <- dat[i,'file']
        fsize <- round(dat[i,'file_size']/1024/1024, 1) 
        if(fsize > maxsize){
          
          # exit with warning
          message(paste0(fname,' was not downloaded because it requires ',fsize,' MB of disk space which exceeds maxsize (',maxsize,' MB). See ?wopr::downloadData\n'))
          
        } else {
          
          # download file
          print(paste('Downloading:', filepath))
          utils::download.file(url = dat[i,'url'], 
                               destfile = filepath, 
                               mode="wb",  
                               quiet=FALSE, 
                               method="auto")  
        }
      }
    }
    writeCatalogue(wopr_dir)
    
  }, warning=function(w) print(w), 
  error=function(e) print(paste('WOPR download ran into an error:',e)))
  
  
  
}
