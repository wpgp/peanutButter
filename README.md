
# peanutButter: An R package for rapid-response gridded population estimates from building footprints

WorldPop Research Group
University of Southampton

10 June 2021

## Introduction

The *peanutButter* R package allows you to produce gridded population estimates from building footprints using the "peanut butter" method. This simple approach involves estimating the average household sizes for each settlement type (e.g. urban and rural) and then spreading those estimates evenly across buildings in each settlement type using high resolution maps of building footprints that are based on recent satellite imagery (Dooley and Tatem 2020, Ecopia.AI and Maxar Technologies 2020).

The *peanutButter* web application is available online from the <a href="https://apps.worldpop.org" target="_blank">WorldPop Applications</a> website.

Code for the *peanutButter* package is openly available on GitHub: <a href='https://github.com/wpgp/peanutButter' target='_blank'>https://github.com/wpgp/peanutButter</a>.

## Installation

First, start a new R session. Then, install the *peanutButter* R package from WorldPop on GitHub:

``` r
devtools::install_github('wpgp/peanutButter')
library(peanutButter)
```

You may be prompted to update some of your existing R packages. This is not required unless the *peanutButter* installation fails. You can avoid checking for package updates by adding the argument `upgrade='never'`. If needed, you can update individual packages that may be responsible for any *peanutButter* installation errors using `install.packages('package_name')`. Or, you can use `devtools::install_github('wpgp/peanutButter', upgrade='ask')` to update all of the packages that *peanutButter* depends on. In R Studio, you can also update all of your R packages by clicking "Tools &gt; Check for Package Updates".

Note: When updating multiple packages, it may be necessary to restart your R session before each installation to ensure that packages being updated are not currently loaded in your R environment.

## Usage

You can list vignettes that are available using: `vignette(package='peanutButter')`

See the vignette for the peanutButter::jelly shiny application using: `vignette('jelly', package='peanutButter')`

### Source data

All of the source files used by peanutButter can be downloaded country-by-country through the web application at <a href="https://apps.worldpop.org/peanutButter" target="_blank">https://apps.worldpop.org/peanutButter</a>.

There are two data sets describing building patterns (<a href="https://dx.doi.org/10.5258/SOTON/WP00666" target="_blank">Dooley and Tatem 2020</a>) that were derived from building footprints (Ecopia.AI and Maxar Technologies 2020):

1.  The count of buildings in each ~100 m grid cell across the country,
2.  A classification of each ~100 m grid cell as urban or rural.

There are also two source datasets that provide the proportion of population in each age-sex group for every ~100 m grid cell (WorldPop et al 2018, Pezullo et al 2017, Carioli et al in prep). The age-sex source files include:

1.  A spreadsheet with age-sex proportions for each region,
2.  A region ID for every 100 m grid cell.

### peanutButter web application

peanutButter includes an R shiny application that allows you to produce rapid-response gridded population estimates from building footprints. The peanutButter application is available on the web at <a href="https://apps.worldpop.org/peanutButter" target="_blank">https://apps.worldpop.org/peanutButter</a>.

You can run the application locally from your R console, but you will first need to download the source files from the web application. Then, run the Shiny application locally using:

``` r
peanutButter::jelly(srcdir="c:/local_source_directory")
```

## Version History

<strong>Version 1.0.0</strong><br> 10 June 2021. Testing period ended and progressed to non-beta version 1 release.

<strong>Version 0.3.2</strong><br> Patch on 22 February 2021 to update the building footprints for 21 countries: BDI, BEN, BFA, BWA, CAF, CMR, COG, DJI, ESH, GHA, GIN, GMB, LSO, MWI, NAM, NER, SSD, TCD, TZA, UGA, and ZMB.

<strong>Version 0.3.1</strong><br> Patch on 30 January 2021 to update the WorldPop logo and to fix a glitch in the source data for Eritrea.

<strong>Version 0.3.0</strong><br> Minor version update on 14 September 2020 to include advanced controls for filtering out buildings based on their area and to distribute population based on building area or building count. Modified default values to match population totals for the year 2020 from the United Nations World Population Prospects (2019; medium-variant projections).

<strong>Version 0.2.1</strong><br> Patch on 9 July 2020 to include building footprints from additional countries for a total of 51 countries.

<strong>Version 0.2.0</strong><br> Minor version update on 3 June 2020 to change terminology from "bottom-up" to "aggregate" and from "top-down" to "disaggregate".

<strong>Version 0.1.0</strong><br> Initial beta release on 27 May 2020.

## Contributing

The *peanutButter* R package was developed by the WorldPop Research Group within the Department of Geography and Environmental Science at the University of Southampton. Funding was provided by the Bill and Melinda Gates Foundation (INV-002697). Ecopia.AI and Maxar Technologies (2020) provided high resolution building footprints based on recent satellite imagery. Gridded age-sex data were provided by the WorldPop Global High Resolution Population Denominators Project led by Alessandro Sorichetta with funding from the Bill and Melinda Gates Foundation (OPP1134076). Development of the *peanutButter* R package was led by Doug Leasure. Claire Dooley developed the source rasters of building counts and urban/rural settlements. Maksym Bondarenko maintains WorldPop's Shiny server. Professor Andy Tatem provides oversight of the WorldPop Research Group.

## Recommended Citation

Leasure DR, Dooley CA, Bondarenko M, Tatem AJ. 2021. peanutButter: An R package to produce rapid-response gridded population estimates from building footprints, version 1.0.0. WorldPop, University of Southampton. doi: 10.5258/SOTON/WP00717. <https://github.com/wpgp/peanutButter>

## License

You are free to redistribute and modify the peanutButter software under the terms of the <a href="https://www.gnu.org/licenses/gpl-3.0.en.html" target="_blank">GNU General Public License v3.0 (GNU GPLv3)</a>. The source code is openly available on <a href="https://github.com/wpgp/peanutButter" target="_blank">GitHub</a>.

The source data for each country is available from the "Source Files" button in the application and the license terms for those datasets are included in the documentation with each download.

## References

Carioli A, Pezzulo C, Hanspal S, Hilber T, Hornby G, Kerr D, Tejedor-Garavito N, Nilsen K, Pistolesi L, Adamo S, Mills J, Nieves JJ, Chamberlain H, Bondarenko M, Lloyd C, Ves N, Koper P, Yetman G, Gaughan A, Stevens F, Linard C, James W, Sorichetta A, and Tatem AJ. In prep. Population structure by age and sex: a multi-temporal subnational perspective.

Ecopia.AI and Maxar Technologies. 2020. Digitize Africa. Ecopia.AI and Maxar Technologies.

Dooley CA, Boo G, Leasure DR, and Tatem AJ. 2020. Gridded maps of building patterns throughout sub-Saharan Africa, version 1.1. WorldPop, University of Southampton. Source of building footprints: Ecopia Vector Maps Powered by Maxar Satellite Imagery (C) 2020. <a href="https://dx.doi.org/10.5258/SOTON/WP00677" target="_blank">doi:10.5258/SOTON/WP00677</a>

Pezzulo C, Hornby GM, Sorichetta A, Gaughan AE, Linard C, Bird TJ, Kerr D, Lloyd CT, Tatem AJ. 2017. Sub-national mapping of population pyramids and dependency ratios in Africa and Asia. Sci. Data 4:170089 <a href="https://dx.doi.org/10.1038/sdata.2017.89" target="_blank">doi:10.1038/sdata.2017.89</a>

WorldPop (www.worldpop.org - School of Geography and Environmental Science, University of Southampton; Department of Geography and Geosciences, University of Louisville; Departement de Geographie, Universite de Namur) and Center for International Earth Science Information Network (CIESIN), Columbia University (2018). Global High Resolution Population Denominators Project - Funded by the Bill and Melinda Gates Foundation (OPP1134076).
