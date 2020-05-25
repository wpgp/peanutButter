#  peanutButter: An R package for rapid-response gridded population estimates from building footprints

WorldPop Research Group  
University of Southampton

25 May 2020

## Introduction

The _peanutButter_ R package allows you to produce gridded population estimates from building footprints using the "peanut butter" method. This simple approach involves estimating the average household sizes for each settlement type (e.g. urban and rural) and then spreading those estimates evenly across buildings in each settlement type using high resolution maps of building footprints that are based on recent satellite imagery (Dooley and Tatem 2020, Ecopia.AI and Maxar Technologies 2020).

Code for the _peanutButter_ package is openly available on GitHub: <a href='https://github.com/wpgp/peanutButter' target='_blank'>https://github.com/wpgp/peanutButter</a>.

**Recommended citation:**
Leasure DR, Dooley CA, Bondarenko M, Tatem AJ. 2020. peanutButter: An R package to produce rapid-response gridded population estimates from building footprints, version 0.1.0. WorldPop Research Group, University of Southampton. <a href="https://github.com/wpgp/peanutButter" target="_blank">doi:10.5258/SOTON/WP00667</a>

## Installation

First, start a new R session. Then, install the _peanutButter_ R package from WorldPop on GitHub:

```r
devtools::install_github('wpgp/peanutButter')
library(peanutButter)
```

You may be prompted to update some of your existing R packages. This is not required unless the _peanutButter_ installation fails. You can avoid checking for package updates by adding the argument `upgrade='never'`. If needed, you can update individual packages that may be responsible for any _peanutButter_ installation errors using `install.packages('package_name')`. Or, you can use `devtools::install_github('wpgp/peanutButter', upgrade='ask')` to update all of the packages that _peanutButter_ depends on. In R Studio, you can also update all of your R packages by clicking "Tools > Check for Package Updates". 

Note: When updating multiple packages, it may be necessary to restart your R session before each installation to ensure that packages being updated are not currently loaded in your R environment.

## Usage

You can list vignettes that are available using: `vignette(package='peanutButter')`

See the vignette for the peanutButter::jelly shiny application using: `vignette('jelly', package='peanutButter')`

### peanutButter web application

peanutButter includes an R shiny application that allows you to produce rapid-response gridded population estimates from building footprints. The peanutButter application is available on the web at <a href="https://apps.worldpop.org/peanutButter" target="_blank">https://apps.worldpop.org/peanutButter</a>. You can also run the application locally from your R console using:

```r
peanutButter::jelly()
```

## Contributing
The _peanutButter_ R package was developed by the WorldPop Research Group within the Department of Geography and Environmental Science at the University of Southampton. Funding was provided by the Bill and Melinda Gates Foundation (INV-002697). Maxar Technologies and Ecopia.AI (2020) provided high resolution building footprints based on recent satellite imagery. Gridded age-sex data were provided by the WorldPop Global High Resolution Population Denominators Project led by Alessandro Sorichetta with funding from the Bill and Melinda Gates Foundation (OPP1134076). Development of the _peanutButter_ R package was led by Doug Leasure. Claire Dooley developed the source rasters of building counts and urban/rural settlements. Maksym Bondarenko maintains WorldPop's Shiny server. Professor Andy Tatem provides oversight of the WorldPop Research Group. 

## Suggested Citation
Leasure DR, Dooley CA, Bondarenko M, Tatem AJ. 2020. peanutButter: An R package to produce rapid-response gridded population estimates from building footprints, version 0.1.0. WorldPop Research Group, University of Southampton. <a href="https://github.com/wpgp/peanutButter" target="_blank">doi:10.5258/SOTON/WP00667</a>

## License
GNU General Public License v3.0 (GNU GPLv3)  

## References

Ecopia.AI and Maxar Technologies. 2020. Digitize Africa.  

Dooley, C. A. and Tatem, A.J. 2020. Gridded maps of building patterns throughout sub-Saharan Africa, version 1.0. University of Southampton: Southampton, UK. Source of building Footprints "Ecopia Vector Maps Powered by Maxar Satellite Imagery"(C) 2020. https://dx.doi.org/10.5258/SOTON/WP00666 



  
  
  
