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
  
  # agesex raster
  srcfile <- file.path(srcdir, srccountry, paste0(srccountry,'_agesex_id.tif'))
  outfile <- file.path(outdir, paste0(country,'_agesex_regions.tif'))
  
  if(!file.exists(outfile) & file.exists(srcfile)){
    cat(paste0(country,': agesex_regions\n'))
    
    agesex_regions <- raster::raster(srcfile)
    
    raster::writeRaster(agesex_regions, outfile, datatype='INT2U')
  }
  
  # agesex table
  srcfile <- file.path(srcdir, srccountry, paste0(srccountry,'_2020_agesex.csv'))
  outfile <- file.path(outdir, paste0(country,'_agesex_table.csv'))
  
  if(!file.exists(outfile) & file.exists(srcfile)){
    cat(paste0(country,': agesex_table\n'))
    
    agesex_table <- read.csv(srcfile)
    
    names(agesex_table)[1] <- 'id'
    
    agesex_table <- agesex_table[,c('id',
                                    names(agesex_table)[grepl('m_',names(agesex_table))],
                                    names(agesex_table)[grepl('f_',names(agesex_table))])]
    
    mcols <- grepl('m_',names(agesex_table))
    fcols <- grepl('f_',names(agesex_table))
    names(agesex_table)[mcols] <- gsub('m_','m',names(agesex_table)[mcols])
    names(agesex_table)[fcols] <- gsub('f_','f',names(agesex_table)[fcols])
    
    write.csv(agesex_table, file=outfile, row.names=F)  
  }
}


