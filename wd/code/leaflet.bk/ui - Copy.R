# left panel: user inputs
inputs <- 
column(
    width=2,
    style=paste0('height: calc(98vh - 75px); padding:30px; overflow-y:scroll; border: 1px solid ',gray(0.9),'; background:',gray(0.95)),
    shinyjs::useShinyjs(),
    
    fluidRow(
        selectInput('data_select', 
            HTML('Select Country<br><small>(see <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">country codes</a>)</small>'),
            choices=country_list, 
            selected=sample(country_list,1)),
        
        sliderInput(inputId = 'prob',
            label = 'Probability of residential building',
            min = 0,
            max = 1,
            value = 0.5,
            step = 0.01),
        
        sliderInput(inputId = 'units',
            label = 'Housing units per building',
            min = 0,
            max = 10,
            value = 1,
            step = 0.1),
        
        sliderInput(inputId = 'people',
            label = 'People per housing unit',
            min = 0,
            max = 10,
            value = 5,
            step = 0.1),
        
        actionButton('build_button', 'Build Raster'),
        
        downloadButton('save_button', 'Download Raster')
    )
)

# main panel
ui <- tagList(
    
    tags$head(
        tags$meta(name='description', content=''),
        tags$meta(name='keywords', content='')
    ), 
    
    tags$style(HTML(".navbar-nav {float:none !important;}
                  .navbar-nav > li:nth-child(2){float:right}")),
    
    tags$style(HTML(".leaflet-container {background:#2B2D2F;}")),
    
    navbarPage(title='sansModel (beta)', 
        inverse=F,
        
        # tab: simulator
        tabPanel('Population Simulator',
            fluidRow(
                
                # inputs panel (left)
                inputs,
                
                # map panel (center)
                column(width = 7,
                    tags$style(type="text/css","#map {height: calc(98vh - 75px) !important;}"),
                    leaflet::leafletOutput('map')),

                # plot panel (right)
                column(width = 2,
                    style='height: calc(98vh - 75px)',
                    tableOutput('table'))
            )
        ),
        
        # tab: WorldPop
        tabPanel(a(href='https://www.worldpop.org', target='_blank', 
            style='padding:0px',
            img(src='logoWorldPop.png', 
                style='height:30px; margin-top:-30px; margin-left:10px')))
        
    )
)
