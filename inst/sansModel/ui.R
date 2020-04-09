# left panel: user inputs
inputs <- 
column(
  width=2,
  style=paste0('height: calc(98vh - 75px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
  shinyjs::useShinyjs(),
  
  fluidRow(
    
    # select data
    selectInput(
      inputId = 'data_select', 
      label = HTML('Select Country<br><small>(see <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">country codes</a>)</small>'),
      choices = row.names(sansModel:::country_info), 
      selected = sample(row.names(sansModel:::country_info),1)),
    
    wellPanel(
      
      strong('Urban Settlements'),
      
      # people per housing unit
      sliderInput(
        inputId = 'people_urb',
        label = h5('People per housing unit'),
        min = 0,
        max = 10,
        value = 5,
        step = 0.1),
      
      # housing units per building
      sliderInput(
        inputId = 'units_urb',            
        label = h5('Housing units per building'),
        min = 0,
        max = 10,
        value = 1,
        step = 0.1),
      
      # probability residential
      sliderInput(
        inputId = 'prob_urb',
        label = h5('Proportion residential buildings'),
        min = 0,
        max = 1,
        value = 0.5,
        step = 0.01)
    ),
    
    wellPanel(
      
      strong('Rural Settlements'),
      
      # people per housing unit
      sliderInput(
        inputId = 'people_rur',
        label = h5('People per housing unit'),
        min = 0,
        max = 10,
        value = 5,
        step = 0.1),
      
      # housing units per building
      sliderInput(
        inputId = 'units_rur',            
        label = h5('Housing units per building'),
        min = 0,
        max = 10,
        value = 1,
        step = 0.1),
      
      # probability residential
      sliderInput(
        inputId = 'prob_rur',
        label = h5('Proportion residential buildings'),
        min = 0,
        max = 1,
        value = 0.5,
        step = 0.01)
    ),
    
    
    # download settings button
    downloadButton('table_button', 'Download Settings')
    
    # download raster button
    downloadButton('raster_button', 'Download Raster')
  )
)

# main panel
ui <- tagList(

tags$style(HTML(".navbar-nav {float:none !important;}
                .navbar-nav > li:nth-child(3){float:right}")),

navbarPage(
  title='sansModel (beta)',              
  inverse=F,
  
  # tab: simulator
  tabPanel(
    title = 'Population Simulator',                      
    
    fluidRow(
      
      # inputs panel (left)
      inputs,
      
      # results panel (center)
      column(
        width = 10,
        style='height: calc(98vh - 75px)',
        tableOutput('table')
        )
      )
    ),
  
  # tab: About
  tabPanel(
    title = 'About'
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
