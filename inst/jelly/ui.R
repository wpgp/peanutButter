# left panel: user inputs
inputs <- 
column(
  width=3,
  style=paste0('height: calc(98vh - 75px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
  shinyjs::useShinyjs(),
  
  fluidRow(
    
    # select data
    selectInput(
      inputId = 'data_select', 
      label = HTML('Select Country<br><small>(see <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">country codes</a>)</small>'),
      choices = row.names(peanutButter:::country_info), 
      selected = sample(row.names(peanutButter:::country_info),1)),
    
    wellPanel(
      
      tags$style('.irs-bar, .irs-bar-edge,
               .irs-single, .irs-from, .irs-to, .irs-grid-pol {background-color:darkgrey; border-color:darkgrey; }'),
      
      strong('Urban Settlements'),
      
      # people per housing unit
      sliderInput(
        inputId = 'people_urb',
        label = h5('Mean people per housing unit'),
        min = 0,
        max = 10,
        value = 0,
        step = 0.1),
      
      # housing units per building
      sliderInput(
        inputId = 'units_urb',            
        label = h5('Mean housing units per building'),
        min = 0,
        max = 10,
        value = 0,
        step = 0.1),
      
      # probability residential
      sliderInput(
        inputId = 'residential_urb',
        label = h5('Proportion residential buildings'),
        min = 0,
        max = 1,
        value = 0,
        step = 0.01)
    ),
    
    wellPanel(
      
      strong('Rural Settlements'),
      
      # people per housing unit
      sliderInput(
        inputId = 'people_rur',
        label = h5('Mean people per housing unit'),
        min = 0,
        max = 10,
        value = 0,
        step = 0.1),
      
      # housing units per building
      sliderInput(
        inputId = 'units_rur',            
        label = h5('Mean housing units per building'),
        min = 0,
        max = 10,
        value = 0,
        step = 0.1),
      
      # probability residential
      sliderInput(
        inputId = 'residential_rur',
        label = h5('Proportion residential buildings'),
        min = 0,
        max = 1,
        value = 0,
        step = 0.01)
    )
  )
)

# main panel
ui <- tagList(

tags$style(HTML(".navbar-nav {float:none !important;}
                .navbar-nav > li:nth-child(3){float:right}")),

navbarPage(
  title='peanutButter::jelly',              
  inverse=F,
  
  # tab: simulator
  tabPanel(
    title = 'Population Simulator',                      
    
    fluidRow(
      
      # inputs panel (left)
      inputs,
      
      # results panel (center)
      column(
        width = 9,
        style='height: calc(98vh - 75px)',
        h4('Results'),
        tableOutput('table_results'),
        h4('Settings'),
        tableOutput('table_settings'),
        downloadButton('raster_button', 'Gridded Population Estimates', style='width:405px'),br(),br(),
        downloadButton('table_button', 'Settings', style='width:200px'),
        downloadButton('source_button', 'Source Files', style='width:200px')
        )
      )
    ),
  
  # tab: About
  tabPanel(
    title = 'About',
    tags$iframe(style='overflow-y:scroll; width:100%; height: calc(98vh - 75px)',
                frameBorder='0',
                src='about.html')
    ),
  
  # tab: WorldPop
  tabPanel(
    a(href='https://www.worldpop.org', target='_blank', 
      style='padding:0px',
      img(src='logoWorldPop.png', 
          style='height:30px; margin-top:-30px; margin-left:10px'))
    )
  )
)
