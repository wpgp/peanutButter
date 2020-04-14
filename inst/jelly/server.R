shinyServer(
function(input, output, session){
  
  # reactive values
  rv <- reactiveValues()

  # load data
  observeEvent(input$data_select, {
    
    # country info
    rv$country_info <- country_info[input$data_select,]
    
    # slider values
    updateSliderInput(session, 'people_urb', value=rv$country_info$people_urb)
    updateSliderInput(session, 'units_urb', value=rv$country_info$units_urb)
    updateSliderInput(session, 'residential_urb', value=rv$country_info$residential_urb)
    updateSliderInput(session, 'people_rur', value=rv$country_info$people_rur)
    updateSliderInput(session, 'units_rur', value=rv$country_info$units_rur)
    updateSliderInput(session, 'residential_rur', value=rv$country_info$residential_rur)
    
    # popup message
    rv$popup_message <- c()
    if(rv$country_info$wopr & rv$country_info$woprVision){
      rv$popup_message[1] <- paste0('There are customized gridded population estimates available for ',input$data_select,'. These data are available for download from the <a href="https://wopr.worldpop.org/?',input$data_select,'" target="_blank">WorldPop Open Population Repository (WOPR)</a> and you can explore those results on an interactive map using the <a href="https://apps.worldpop.org/woprVision" target="_blank">woprVision web application</a>.')
    } else if(rv$country_info$wopr) {
      rv$popup_message[1] <- paste0('There are customized gridded population estimates available for ',input$data_select,'. These data are available for download from the <a href="https://wopr.worldpop.org/?',input$data_select,'" target="_blank">WorldPop Open Population Repository (WOPR)</a>.')
    }
    
    if(rv$country_info$partial_footprints){
      rv$popup_message[length(rv$popup_message)+1] <- paste0('Warning: The building footprints for ',input$data_select,' do not have complete national coverage. Download the source files to see the coverage.')
    }
    
    if(!is.null(rv$popup_message[1])){
      showModal(modalDialog(HTML(paste(rv$popup_message,collapse='<br><br>')), 
                            title='Friendly Message:',
                            footer=tagList(modalButton('Okay, thanks.'))
      ))
    }
  })
  
  # population total
  observe({
    rv$pop_urb <- rv$country_info$urb_count*input$residential_urb*input$units_urb*input$people_urb
    rv$pop_rur <- rv$country_info$rur_count*input$residential_rur*input$units_rur*input$people_rur
    
    rv$pop_total <- rv$pop_urb + rv$pop_rur
    
    rv$table <- data.frame(settings=matrix(c(prettyNum(round(rv$pop_total), big.mark=','), 
                                             prettyNum(round(rv$pop_urb), big.mark=','), 
                                             prettyNum(round(rv$pop_rur), big.mark=','), 
                                             prettyNum(round(input$people_urb,1), big.mark=','), 
                                             prettyNum(round(input$units_urb,1), big.mark=','), 
                                             paste0(round(input$residential_urb*100),'%'),
                                             prettyNum(round(rv$country_info$urb_count), big.mark=','), 
                                             prettyNum(round(input$people_rur,1), big.mark=','), 
                                             prettyNum(round(input$units_rur,1), big.mark=','), 
                                             paste0(round(input$residential_rur*100),'%'),
                                             prettyNum(round(rv$country_info$rur_count), big.mark=',')
                                             ), 
                                           ncol=1),
                           row.names=c('Population Total',
                                       'Population Urban',
                                       'Population Rural',
                                       'Urban: People per housing unit',
                                       'Urban: Housing units per building',
                                       'Urban: Proportion residential buildings',
                                       'Urban: Total buildings',
                                       'Rural: People per housing unit',
                                       'Rural: Housing units per building',
                                       'Rural: Proportion residential buildings',
                                       'Rural: Total buildings'
                                       ))
    })
  
  # results table
  output$table_results <- renderTable(data.frame(rv$table[1:3,], row.names=row.names(rv$table)[1:3]), 
                              digits = 0,
                              striped = T,
                              colnames = F,
                              rownames = T,
                              format.args = list(big.mark=",", decimal.mark="."))
  
  # settings table
  output$table_settings <- renderTable(data.frame(rv$table[4:nrow(rv$table),], row.names=row.names(rv$table)[4:nrow(rv$table)]), 
                              digits = 0,
                              striped = T,
                              colnames = F,
                              rownames = T,
                              format.args = list(big.mark=",", decimal.mark="."))
  
  # download settings button
  output$table_button <- downloadHandler(filename = function() paste0(input$data_select,'_settings_',format(Sys.time(), "%Y%m%d%H%M"),'.csv'),
                                         content = function(file) {
                                           withProgress({
                                             write.csv(rv$table, file, row.names=T) 
                                           }, 
                                           message='Preparing data:', 
                                           detail='Creating .csv table with a record of your settings...', 
                                           value=0.5)
                                           })
  
  
  # download raster button
  output$raster_button <- downloadHandler(filename = function() paste0(input$data_select,'_population_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'),
                                          content = function(file) {
                                            withProgress({
                                              raster::writeRaster(x = popRaster(buildings_path = file.path(srcdir,paste0(input$data_select,'_buildings.tif')),
                                                                                urban_path = file.path(srcdir,paste0(input$data_select,'_urban.tif')),
                                                                                people_urb = input$people_urb,
                                                                                units_urb = input$units_urb,
                                                                                residential_urb = input$residential_urb,
                                                                                people_rur = input$people_rur,
                                                                                units_rur = input$units_rur,
                                                                                residential_rur = input$residential_rur
                                                                                ),
                                                                  filename = file)
                                            }, 
                                            message='Preparing data:', 
                                            detail='Creating .tif raster with your gridded population estimates...', 
                                            value=0.5)
                                            })
  
  
  # download source button
  output$source_button <- downloadHandler(filename = function() paste0(input$data_select,'_source_',format(Sys.time(), "%Y%m%d%H%M"),'.zip'),
                                          content = function(file) {
                                            withProgress({
                                              zip::zipr(zipfile = file,
                                                        files = c(file.path(srcdir,paste0(input$data_select,'_buildings.tif')),
                                                                  file.path(srcdir,paste0(input$data_select,'_urban.tif')))
                                                        )
                                            }, 
                                            message='Preparing data:', 
                                            detail='Creating zip archive with our source data rasters...', 
                                            value=0.5)
                                          })
                                          
  })




