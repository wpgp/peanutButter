# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# libraries
library(sansModel)

# load building count raster
bldg_raster <- raster::raster('in/GHA_building_count.tif')

# total buildings
total_buildings <- raster::cellStats(bldg_raster, stat='sum')

# number of sims
n <- 1e3

# residential probability
mu_res_prob <- 0.5
unc_res_prob <- 0.005
res_prob <- rbeta(n, mu_res_prob/unc_res_prob, (1-mu_res_prob)/unc_res_prob)
hist(res_prob, main='Residential Probability', xlab='probability')

# residential buildings
residential_buildings <- rbinom(n, 
                                size = total_buildings,
                                prob = res_prob)

# housing units per building
mu_units <- 0.1
unc_units <- 1
units <- rtpois(n, 
                lambda = rgamma(n, mu_units^2/unc_units^2, mu_units/unc_units^2),
                min = 1)
hist(units, main=paste0('Housing Units\nmean=',mean(units)), xlab='housing units / building')
mean(units)

# people per housing unit
mu_pph <- 4
unc_pph <- 0.2
pph <- rtpois(n,
              lambda = rgamma(n, mu_pph^2/unc_pph^2, mu_pph/unc_pph^2),
              min = 1)
hist(pph, main='Household Size', xlab='people / housing unit')
mean(pph)

# deterministic population total
total_pop0 <- total_buildings * mu_res_prob * mu_units * mu_pph

# stochastic population total
total_pop1 <- total_buildings * mean(res_prob) * mean(units) * mean(pph)

# stochastic population total
total_pop2 <- residential_buildings * units * pph
mean(total_pop2)
