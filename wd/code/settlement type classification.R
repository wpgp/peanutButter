
rm(list=ls())

library(raster)
library(data.table)
library(fasterize)
library(smoothr)
library(stars)

setwd("Z:/Projects/WP517763_GRID3/Working/ZMB/covariates/out/settlement/EcopiaBF_derived/bcentroid")
bsett <- raster("ZMB_ecopiaBF_bcentroid_settled_binary_100m.tif")
mgrid <- raster("Z:/Projects/WP517763_GRID3/Working/ZMB/covariates/mastergrid/GRID3_ZMB_mastergrid.tif")
bsett <- crop(bsett, extent(mgrid))

clumps <- clump(bsett, directions=8)

area <- raster("ZMB_ecopiaBF_bcentroid_area_100m.tif")
area <- crop(area, extent(mgrid))

# create results data table 
clumpdt <- data.table(clump_ID = clumps[],
                   bfarea = area[])
clumpdt <- clumpdt[!is.na(clump_ID),]
cell_count_dt <- clumpdt[,.N,by=clump_ID]
nrow(cell_count_dt)   # 629,789 clumps
area_dt <- clumpdt[,.(sumarea=sum(bfarea)),by=clump_ID]
nrow(area_dt)   # 629,789 clumps
clump_sum_dt <- merge(cell_count_dt,area_dt, by='clump_ID')

big_clumps <- clump_sum_dt[N >= 500 & sumarea >= 100000]
nrow(big_clumps)      

clumps2 <- clumps
clumps2[!clumps2 %in% big_clumps$clump_ID] <- NA

big_clumps <- clump_sum_dt[N >= 1500 & sumarea >= 100000]
nrow(big_clumps)      

clumps3 <- clumps2
clumps3[!clumps3 %in% big_clumps$clump_ID] <- NA


### create settlement layer

sl <- clumps
sl[!is.na(sl)] <- 1
sl[!is.na(clumps2)] <- 2
sl[!is.na(clumps3)] <- 3
sl[bsett == 0] <- NA

setwd("Z:/Personal/cad1c14/ZMB_working/survey_data_prep/made_data_files")
writeRaster(sl,"sett_type.tif")


### non-resid areas

setwd("Z:/Personal/cad1c14/ZMB_working/survey_data_prep/made_data_files/zmb_bf_large_buildings_buffer_wgs")
bf_lb_wgs_dis <- read_sf("zmb_bf_large_buildings_buffer_wgs.shp")

bf_lb_raster <- fasterize(bf_lb_wgs_dis,mgrid)

setwd("Z:/Personal/cad1c14/ZMB_working/survey_data_prep/made_data_files")
#writeRaster(bf_lb_raster,"zmb_bf_large_buildings_buffer_wgs.tif")

adj_cells <- adjacent(bf_lb_raster,cells=which(bf_lb_raster[]==1),directions=8,pairs=TRUE)
adj_cells <- adj_cells[,2]
#tcells <- adj_cells[duplicated(adj_cells)]
adj_Cells_tab <- table(adj_cells)
tcells <- as.numeric(names(adj_Cells_tab[which(adj_Cells_tab > 3)]))
bf_lb_raster[tcells] <- 1

#convert to polygon, fill in areas surrounded by non-resid 
nonresid <- st_as_stars(bf_lb_raster) %>% 
  st_as_sf(merge = TRUE)

test <- fill_holes(nonresid, threshold=1000000)
#write_sf(test,"nonresid_regions.shp")

# raster of non-resid classified regions
nonresid <- fasterize(test,mgrid)

nr_clumps <- clump(nonresid, directions=8)
nrclumpdt <- data.table(clump_ID = nr_clumps[])
nrclumpdt <- nrclumpdt[!is.na(clump_ID),]
nr_cell_count_dt <- nrclumpdt[,.N,by=clump_ID]
big_clumps <- nr_cell_count_dt[N >= 4]
nrow(big_clumps)      

nr_clumps[!nr_clumps %in% big_clumps$clump_ID] <- NA
nr_clumps[bsett == 0] <- NA

setwd("Z:/Personal/cad1c14/ZMB_working/survey_data_prep/made_data_files")
writeRaster(nr_clumps,"nonresid.tif")


## define cluster sett types

# read in cluster boundaries
setwd("Z:/Personal/cad1c14/ZMB_working/survey_data_prep/made_data_files")
cb <- read_sf("cluster_boundaries_all_surveys_no_overlap.shp")
cb <- cb[,2:3]


# read in sett type and nonresid rasters
sl <- raster("sett_type.tif")
nr <- raster("nonresid.tif")
nr[!is.na(nr)] <- 1


# extract raster vals in polys 


settls <- lapply(1:nrow(cb),function(i){
x <- which(!is.na(values(fasterize(cb[i,], mgrid))))
slx <- sl[x]
slx <- slx[!is.na(slx)]
tx <- table(slx)
if(length(tx)>0){
  setttype <- as.numeric(names(tx[which(tx==max(tx))]))
  if(length(setttype)>1){setttype <- max(setttype)}
}else{
  setttype <- 0
}
nrx <- nr[x]
nrx <- nrx[!is.na(nrx)]
c(i,setttype,length(slx),length(nrx))
})

setttab <- do.call(rbind,settls)
colnames(setttab) <- c('ucid','sett_type','sett_pixels','nonresid_sett_pixels')
#write.csv(setttab,"cluster_sett_data.csv",row.names = FALSE)





