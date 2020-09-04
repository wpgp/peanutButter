# controls: bottom-up 
controls_bottomup1 <- 
  
  wellPanel(id='aggregate_controls1', 
            strong('Urban Settlements'),
            
            sliderInput('pph_urb',
                        label = h5('Mean people per housing unit'),
                        min = 1, max = 10, value = 0, step = 0.1),
            
            sliderInput('hpb_urb',            
                        label = h5('Mean housing units per residential building'),
                        min = 1, max = 3, value = 0, step = 0.1),
            
            sliderInput('pres_urb',
                        label = h5('Proportion building footprints that are residential'),
                        min = 0, max = 1, value = 0, step = 0.01),
            
            shinyjs::hidden(
              sliderInput('ppa_urb',
                          label = h5('Mean people per building area (ha)'),
                          min = 0, max = 1500, value = 0, step = 1))
            )

controls_bottomup2 <-
  wellPanel(id='aggregate_controls2', 
            strong('Rural Settlements'),
            
            sliderInput('pph_rur',
                        label = h5('Mean people per housing unit'),
                        min = 1, max = 10, value = 0, step = 0.1),
            
            sliderInput('hpb_rur',            
                        label = h5('Mean housing units per residential building'),
                        min = 1, max = 3, value = 0, step = 0.1),
            
            sliderInput('pres_rur',
                        label = h5('Proportion building footprints that are residential'),
                        min = 0, max = 1, value = 0, step = 0.01),
            
            shinyjs::hidden(
              sliderInput('ppa_rur',
                          label = h5('Mean people per building area (ha)'),
                          min = 0, max = 1500, value = 0, step = 1)
            )
          )

# controls: top-down
controls_topdown <- 
  wellPanel(id='disaggregate_controls',
            strong('Upload Polygons (GeoJson)'),
            
            fileInput("user_json", 
                      NULL,
                      multiple = FALSE,
                      accept = c("application/json",".geojson",".json"),
                      buttonLabel = 'Browse'),
            
            selectInput(inputId = 'popcol', 
                        label = 'Column name with population totals',
                        choices = '(no polygons uploaded)')
            )

# controls: age-sex
controls_agesex <-
  wellPanel(strong('Age-sex Selection'),br(),
            
            'The gridded population estimates that you download will represent the population within the selected age-sex groups.',
            br(),br(),
            
            splitLayout(cellWidths=c('25%','75%'),
                        
                        checkboxInput(inputId="female_toggle", label="Female", value=T),
                        
                        shinyWidgets::sliderTextInput(inputId="female_select",
                                                      label=NULL,
                                                      choices=c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+'),
                                                      selected=c('<1', '80+'),
                                                      force_edges=T,
                                                      grid=T)),
            
            splitLayout(cellWidths=c('25%','75%'),
                        
                        checkboxInput(inputId="male_toggle", label="Male", value=T),
                        
                        shinyWidgets::sliderTextInput(inputId="male_select",
                                                      label=NULL,
                                                      choices=c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+'),
                                                      selected=c('<1', '80+'),
                                                      force_edges=T,
                                                      grid=T)),
            'Note: The on-screen results in the "Aggregate" tab represent total populations and do not change with your age-sex selection.'
          )

# controls: advanced
controls_advanced <-
  wellPanel(h4('Advanced'),
            
            strong('Size Thresholds for Residential Buildings'), br(),
            'You can choose to assume that no people live in the buildings with the smallest and/or largest building footprints.', br(), br(),
            
            'Minimum residential building footprint area (sq m)', br(),
            sliderInput('bld_min_area', 
                        label=NULL, min=0, max=10, value=0, step=1),
            
            'Maximum residential building footprint area (sq m)', br(),
            sliderInput('bld_max_area', 
                        label=NULL, min=1e3, max=max_building, value=max_building, step=500), br(),
            
            strong('Unit of Analysis'), br(),
            'The population can be estimated based on the count of buildings or the total area of buildings.', br(), br(),
            
            radioButtons('units_count',
                         label=NULL, 
                         choiceNames = c('Building count','Building area'),
                         choiceValues = c(T,F)),
            'Note: Changing the unit of analysis will modify the controls in the "Aggregate" tab.'
          )


ui <- fluidPage(
  
  shinyjs::useShinyjs(),

  tags$style(HTML(".navbar-nav {float:none !important;}
                .navbar-nav > li:nth-child(4){float:right}")),
  
  fluidRow(
    

    ####-- control panel (left) --####
    column(width=3, style=paste0('height:calc(100vh); border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
       
      fluidRow(
        titlePanel(HTML('<div style="font-family:Helvetica,Arial,sans-serif;
                         font-size:20px; padding-left:5px; color:#727272; background:#F2F2F2">
                         peanutButter (beta)</div>'),
                   windowTitle='peanutButter'),
        
        # controls: select country
        div(style='padding-left:15px',
            selectInput('data_select',
                    label = HTML('Select Country<br><small>(see <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">country codes</a>)</small>'),
                    choices = row.names(country_info), 
                    selected = initialize_country))
      ),
           
      fluidRow(
        column(width=12, style=paste0('height:calc(83vh); overflow-y:scroll; background:',gray(0.95)),
               
               controls_bottomup1,
               controls_bottomup2,
               controls_topdown,
               controls_agesex,
               controls_advanced)
        )
      ),
    
    ####-- results panel (center) --####
    column(width=9, 
      
      navbarPage(title=NULL, id='tabs',

        tabPanel('Aggregate',                      
           h4('Do-It-Yourself Gridded Population Estimates'),
           div(style='width:600px',
               HTML('The <strong>"aggregate" tool</strong> will apply your estimates of people per building to every building and then aggregate buildings to estimate population size for each ~100 m grid cell.<br><br>
                    Move the sliders on the left panel to adjust settings and then click "Update Results" to calculate a summary of the population estimates that will appear in the table below.<br><br>
                    When you are satisfied that the settings and the results are reasonable, use the "Gridded Population Estimates" button to download a 100 meter population grid (geotiff raster, WGS84) created by applying your settings to a high resolution map of building footprints.<br><br>
                    See the "About" tab for details about the method and source data.<br><br>')),
           actionButton('submit',strong('Retrieve/Update Results'), style='width:405px'),br(),br(),
           tableOutput('table_results'),
           downloadButton('raster_buttonBU', strong('Gridded Population Estimates'), style='width:405px'),br(),br(),
           downloadButton('table_buttonBU', 'Settings', style='width:200px'),
           downloadButton('source_buttonBU', 'Source Files', style='width:200px')
        ),
        
        tabPanel('Disaggregate',
           h4('Do-It-Yourself Gridded Population Estimates'),
           div(style='width:600px', HTML('The <strong>"disaggregate" tool</strong> allows you to disaggregate your own population totals from administrative units (or other polygons) into gridded population estimates based on a high resolution map of building footprints.<br><br>
                                         Provide a polygon shapefile (GeoJson format) that contains the total population for each polygon.<br><br>
                                         After you upload your polygons, click the "Gridded population estimates" button and the peanutButter application will disaggregate your population totals into a 100 m grid based on building footprints.<br><br>
                                         See the "About" tab for details about the method and source data.<br><br>')),
           downloadButton('raster_buttonTD', strong('Gridded Population Estimates'), style='width:405px'),
           downloadButton('source_buttonTD', 'Source Files', style='width:200px'),
           br(),br()
        ),
        
        tabPanel('About',
                 tags$iframe(style='overflow-y:scroll; width:100%; height:calc(89vh)',
                             frameBorder='0',
                             src='about.html')
        ),
        
        tabPanel(
          a(href='https://www.worldpop.org', target='_blank', 
            style='padding:0px',
            img(src='logoWorldPop.png', 
                style='height:30px; margin-top:-30px; margin-left:10px'))
        )
      ),
      tags$footer(HTML(paste0('<a href="https://github.com/wpgp/peanutButter" target="_blank">peanutButter v',packageVersion('peanutButter'),'</a>')),
                  align = 'right')
    )
  )
)