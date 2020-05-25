# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# packages
library(peanutButter, lib='c:/research/r/library')

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# source directory
srcdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP515640_Global/Raster/AgeSexProp/PRODUCTION_FOLDER/ALL'

# destination directory
outdir <- '//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/Working/git/peanutButter'

# country list
country_list <- as.character(peanutButter:::country_info$country)

# process countries
for(country in country_list){
  
  srccountry <- ifelse(country=='CAR','CAF',country)
  
  # source files
  srcfile_raster <- file.path(srcdir, srccountry, paste0(srccountry,'_agesex_id.tif'))
  srcfile_table <- file.path(srcdir, srccountry, paste0(srccountry,'_2020_agesex.csv'))
  
  # output files
  outfile_raster <- file.path(outdir, paste0(country,'_agesex_regions.tif'))
  outfile_table <- file.path(outdir, paste0(country,'_agesex_table.csv'))
  
  if(!file.exists(outfile_raster) | !file.exists(outfile_table)){
    
    cat(paste0(country,'\n'))
    
    if(!file.exists(srcfile_raster) | !file.exists(srcfile_table)){
      warning(paste0(country,': source file(s) missing.'));next()
    } 
    
    # load source
    agesex_raster <- raster::raster(srcfile_raster)
    agesex_table <- read.csv(srcfile_table)
    
    # fix bad column names
    names(agesex_table)[names(agesex_table)=="ï..id"] <- 'id'
    
    # add new id to agesex_table
    agesex_table$new_id <- 1:nrow(agesex_table)
    
    # save raster coordinate system
    crs1 <- raster::crs(agesex_raster)
    ex1 <- raster::xmin(agesex_raster)
    ex2 <- raster::xmax(agesex_raster)
    ex3 <- raster::ymin(agesex_raster)
    ex4 <- raster::ymax(agesex_raster)
    
    # raster to matrix
    new_agesex_raster <- agesex_raster <- raster::as.matrix(agesex_raster)
    
    # proportions to matrix
    for(id in agesex_table$id){
      new_agesex_raster[which(agesex_raster==id)] <- agesex_table[agesex_table$id==id,'new_id']
    }
    
    # rasterize group proportions
    agesex_raster <- raster::raster(new_agesex_raster, crs=crs1, xmn=ex1, xmx=ex2, ymn=ex3, ymx=ex4)
    rm(new_agesex_raster)
    
    # rename id columns
    names(agesex_table)[which(names(agesex_table)=='id')] <- 'old_id'
    names(agesex_table)[which(names(agesex_table)=='new_id')] <- 'id'
    
    # check source
    if(!'id' %in% names(agesex_table)){
      warning(paste0(country,': the region "id" column is missing from the table.'));next()
    }
    
    if(!all(raster::unique(agesex_raster) %in% unique(agesex_table$id))){
      warning(paste0(country,': at least one region is missing from the table.'));next()
    }
    
    if(!36==sum(grepl('f_',names(agesex_table)),grepl('m_',names(agesex_table)))){
      warning(paste0(country,': at least one demographic group is missing from the table.'));next()
    }
    
    # agesex table: subset to required columns
    agesex_table <- agesex_table[,c('id',
                                    names(agesex_table)[grepl('m_',names(agesex_table))],
                                    names(agesex_table)[grepl('f_',names(agesex_table))])]
    
    # agesex table: reformat column names
    mcols <- grepl('m_',names(agesex_table))
    fcols <- grepl('f_',names(agesex_table))
    names(agesex_table)[mcols] <- gsub('m_','m',names(agesex_table)[mcols])
    names(agesex_table)[fcols] <- gsub('f_','f',names(agesex_table)[fcols])
    
    if(nrow(agesex_table) < length(raster::unique(agesex_raster))){
      warning(paste0(country,': final table has fewer regions than raster'));next()
    }
    
    if(!ncol(agesex_table)==37){
      warning(paste0(country,': final table has wrong number columns '));next()
    }
    
    # save results
    raster::writeRaster(agesex_raster, outfile_raster, datatype='INT2U', overwrite=F)
    write.csv(agesex_table, file=outfile_table, row.names=F)
  }
}


