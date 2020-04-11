shinyServer(
function(input, output, session){
  
  # reactive values
  rv <- reactiveValues()

  # load data
  observeEvent(input$data_select, {
    rv$bld_count <- peanutButter:::country_info[input$data_select,'bld_count']
    rv$urb_count <- peanutButter:::country_info[input$data_select,'urb_count']
    rv$rur_count <- peanutButter:::country_info[input$data_select,'rur_count']
    
    updateSliderInput(session, 'people_urb', value=country_info[input$data_select,'people_urb'])
    updateSliderInput(session, 'units_urb', value=country_info[input$data_select,'units_urb'])
    updateSliderInput(session, 'residential_urb', value=country_info[input$data_select,'residential_urb'])
    
    updateSliderInput(session, 'people_rur', value=country_info[input$data_select,'people_rur'])
    updateSliderInput(session, 'units_rur', value=country_info[input$data_select,'units_rur'])
    updateSliderInput(session, 'residential_rur', value=country_info[input$data_select,'residential_rur'])
    
  })
  
  # population total
  observe({
    rv$pop_urb <- rv$urb_count*input$residential_urb*input$units_urb*input$people_urb
    rv$pop_rur <- rv$rur_count*input$residential_rur*input$units_rur*input$people_rur
    
    rv$pop_total <- rv$pop_urb + rv$pop_rur
    
    rv$table <- data.frame(settings=matrix(c(prettyNum(round(rv$pop_total), big.mark=','), 
                                             prettyNum(round(rv$pop_urb), big.mark=','), 
                                             prettyNum(round(rv$pop_rur), big.mark=','), 
                                             prettyNum(round(input$people_urb,1), big.mark=','), 
                                             prettyNum(round(input$units_urb,1), big.mark=','), 
                                             paste0(round(input$residential_urb,1)*100,'%'),
                                             prettyNum(round(input$people_rur,1), big.mark=','), 
                                             prettyNum(round(input$units_rur,1), big.mark=','), 
                                             paste0(round(input$residential_rur*100,1),'%'),
                                             prettyNum(round(rv$bld_count), big.mark=','), 
                                             prettyNum(round(rv$urb_count), big.mark=','), 
                                             prettyNum(round(rv$rur_count), big.mark=',')
                                             ), 
                                           ncol=1),
                           row.names=c('Population Total',
                                       'Population Urban',
                                       'Population Rural',
                                       'People per housing unit (urban)',
                                       'Housing units per building (urban)',
                                       'Proportion residential buildings (urban)',
                                       'People per housing unit (rural)',
                                       'Housing units per building (rural)',
                                       'Proportion residential buildings (rural)',
                                       'Buildings Total',
                                       'Buildings Urban',
                                       'Buildings Rural'
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
  output$table_button <- downloadHandler(filename = paste0(input$data_select,'_',format(Sys.time(), "%Y%m%d%H%M"),'.csv'),
                                          content = function(file) {
                                            write.csv(rv$table, file, row.names=T) 
                                          })
  
  # download raster button
  output$raster_button <- downloadHandler(filename = paste0(input$data_select,'_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'),
                                        content = function(file) {
                                          raster::writeRaster(popRaster(buildings_path = file.path(srcdir,paste0(input$data_select,'_buildings.tif')),
                                                                        urban_path = file.path(srcdir,paste0(input$data_select,'_urban.tif')),
                                                                        people_urb = input$people_urb,
                                                                        units_urb = input$units_urb,
                                                                        residential_urb = input$residential_urb,
                                                                        people_rur = input$people_rur,
                                                                        units_rur = input$units_rur,
                                                                        residential_rur = input$residential_rur
                                                                        ), 
                                                              file)
                                          })
  
  # download source button
  output$source_button <- downloadHandler(filename = paste0(input$data_select,'_source_',format(Sys.time(), "%Y%m%d%H%M"),'.zip'),
                                          content = function(file) {
                                            zip::zipr(zipfile = file,
                                                      files = c(file.path(srcdir,paste0(input$data_select,'_buildings.tif')),
                                                                file.path(srcdir,paste0(input$data_select,'_urban.tif')))
                                                       )
                                          })
})




