# peanutButter::jelly
# A tool to produce quick gridded population estimates using the peanut butter method
WorldPop Research Group, University of Southampton  

#### Overview

The *peanutButter::jelly* application allows you to produce gridded population estimates from building footprints using the "peanut butter" method. This simple approach involves estimating the average household sizes for each settlement type (e.g. urban and rural) and then spreading those estimates evenly across the landscape in each settlement type. High resolution maps of building footprints (Maxar Technologies & Ecopia.AI 2020) are used to map where households are likely to occur.

*peanutButter* is an R package that provides this functionality from the R statistical programming console and *jelly* is a shiny web application that provides a web-based graphical user interface. Code for the *peanutButter* R package and the *peanutButter::jelly* web application are openly available from WorldPop on GitHub: https://github.com/wpgp/peanutButter.

#### Steps
1. Explore population parameters until you find a combination that produces reasonable estimates of total population, urban population, and rural population for the country as a whole.  

2. Use the "Save Population Raster" button to generate a gridded population map (a geotiff raster) that is produced by applying your population parameters to building footprints in each approximately 100 m grid cell across the country.  

3. Use the "Save Settings" button to save a .csv spreadsheet with your population parameters.

#### Method

The peanutButter::jelly method requires you to estimate three population characteristics for both urban and rural settlement types using expert opinion:  

1. Mean number of people per housing unit  
2. Mean number of housing units per building  
3. Proportion of buildings that are residential  

The population is estimated using the following formula:  

`Population = TotalBuildings x ProportionResidential x UnitsPerBuilding x PeoplePerUnit`

There are two datasets working behind the scenes in the application (WorldPop et al. 2020):  

1. The count of buildings in each ~100 m grid cell across the country,  
2. A classification of each ~100 m grid cell as urban or rural.

#### Advantages  
- This method is quick and easy to implement in situations where suitable population estimates are not currently available.  
- High resolution building footprints provide a valuable source of information about where populations are located and their relative densities.

#### Disadvantages
- This method is not objective or driven by population data (i.e. household surveys). It relies on your subjective estimates of population characteristics.  
- There are no estimates of uncertainty provided by this method. You will have no objective basis for determing the accuracy the estimates produced.  

#### Citations
Maxar Technologies and Ecopia.AI. 2020. Digitize Africa Data, Building Footprints.  
WorldPop, Maxar Technologies, and Ecopia.AI. 2020. Gridded maps of building patterns throughout sub-Saharan Africa.
