# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# load UN data
dat <- read.csv('WPP2019_TotalPopulationBySex.csv')

# load peanutButter defaults
defaults <- read.csv('../data-raw/defaults.csv')

# subset UN dat
dat <- dat[dat$Variant=='Medium' & dat$Time==2020,]

# set country totals
not_found <- c()
for(i in 1:nrow(defaults)){

  country_name <- defaults$country_name[i]

  if(country_name=='Congo, Democratic Republic of the') country_name <- 'Democratic Republic of the Congo'
  if(country_name=='Cote dIvoire') country_name <- "Côte d'Ivoire"
  if(country_name=='Reunion') country_name <- "Réunion"
  if(country_name=='Tanzania, United Republic of') country_name <- 'United Republic of Tanzania'

  if(country_name %in% dat$Location){
    cat(paste(defaults$country_name[i],'\n'))
    defaults[i,'population'] <- dat[dat$Location==country_name,'PopTotal'] * 1e3
  }

  else if(!defaults$country_name[i] == '') {
    not_found <- c(not_found, defaults$country_name[i])
    warning(paste(defaults$country_name[i], 'not found in UN Population Prospects data.'))
  }
}

# save defaults
write.csv(defaults, file='../data-raw/defaults.csv', row.names=F)
