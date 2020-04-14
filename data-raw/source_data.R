
# This R script creates the two input rasters per country for the peanutButter app
# The two rasters are:
# 1. building count per pixel (based on building centroids)
# 2. binary classification of urban (1=yes; 0=no)
# Both are derived from Building Footprints (Digitize Africa data © 2020 Maxar Technologies, Ecopia.AI)
# Both are based on the WorldPop country master grids (ftp://ftp.worldpop.org/GIS/Mastergrid/Global_2000_2020/)
# Pixels are classed as urban if they are inside a grouping of pixels that is greater than 
# or equal to 1,500 pixels and contains at least 5,000 buildings


rm(list=ls())

library(sf)
library(rgdal)
library(rgeos)
library(data.table)
library(curl)


# define directories

# directory contain building footprints
raw_dir <- 'XX' 

# directory for output files to be saved
output_dir <- 'YY'

# directory for temporary master grid rasters to be saved 
temp_dir <- 'YY'



# list of countries with building footprints data
setwd(raw_dir)
full <- list.dirs(path=paste(getwd()),full.names=FALSE,recursive=TRUE) 
gdbfolders <- full[grep(".gdb",full)]

# list countries that already have layers created 
existingfiles <- list.files(output_dir)
existingcountries <- unique(substring(existingfiles,1,3))

gdbfolders <- gdbfolders[!substring(gdbfolders,1,3) %in% existingcountries]

for(countryit in 1:length(gdbfolders)){
  
  # save country iso code
  isocode <- substring(gdbfolders[countryit],1,3)
  
  # list all feature classes in the file geodatabase
  fgdb <- gdbfolders[countryit]
  fc_list <- ogrListLayers(fgdb)
  
  # create centroids for each of the feature classes
  centroids_wgs <- list()
  for(i in 1:length(fc_list)){
    bf <- read_sf(dsn=fgdb,layer=paste(fc_list[i]))
    centroids_utm <- st_centroid(bf)
    rm(bf)
    centroids_wgs[[i]] <- st_transform(centroids_utm, crs ="+proj=longlat +datum=WGS84") # reproject
    rm(centroids_utm)
  }
  
  # merge centroid layers
  centroids_wgs_master <- do.call(rbind, centroids_wgs)
  rm(centroids_wgs)
  
  # read in master grid
  urlx <- paste("ftp://ftp.worldpop.org/GIS/Mastergrid/Global_2000_2020/",isocode,"/L0/",tolower(isocode),"_level0_100m_2000_2020.tif",sep='')
  utils::download.file(url = urlx,
                       destfile = paste(temp_dir,"/temp.tif",sep=''),
                       mode="wb",
                       quiet=FALSE,
                       method="libcurl")
  
  mg <- raster(paste(temp_dir,"/temp.tif",sep=''))
  
  # get cellID for each building
  points_IDs <- cellFromXY(mg, as(centroids_wgs_master, "Spatial"))
  dt <- data.table(cellID = points_IDs)
  dt <- na.omit(dt)
  rm(points_IDs)
  
  # building count per cellID
  bc <- dt[,.N,by=cellID]
  
  # create raster based on mastergrid
  mgrid <- mg
  mgrid[] <- NA
  mgrid[bc$cellID] <- bc$N
  
  # building count raster
  raster::writeRaster(mgrid, filename = paste(output_dir,'/',isocode,'_buildings.tif',sep=''),datatype='INT2U')
  
  # identify 'clumps' 
  clumps <- clump(mgrid, directions=8)
  
  # data table for cells
  clumpdt <- data.table(clump_ID = clumps[],
                        bfcount = mgrid[])
  clumpdt <- clumpdt[!is.na(clump_ID),]
  
  # cell count per clump
  cell_count_dt <- clumpdt[,.N,by=clump_ID]

  # bf count per clump
  bfcount_dt <- clumpdt[,.(sumcount=sum(bfcount)),by=clump_ID]
  
  # clumps table
  clump_sum_dt <- merge(cell_count_dt, bfcount_dt, by='clump_ID')
  
  # urban threshold
  big_clumps <- clump_sum_dt[N >= 1500 & sumcount >= 5000,]
  
  # ids for urban and rural
  sl <- clumps
  sl[!is.na(clumps)] <- 0
  sl[clumps %in% big_clumps$clump_ID] <- 1
  
  # urban raster (urban=1, rural=0, unsettled=NA)
  raster::writeRaster(sl, filename=paste(output_dir,'/',isocode,'_urban.tif',sep=''), datatype='LOG1S')
  
  unlink(paste(temp_dir,"/temp.tif",sep=''))
  
}

