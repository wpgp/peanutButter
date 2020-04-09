shinyServer(
function(input, output, session){
  
  # reactive values
  rv <- reactiveValues()

  # load data
  observeEvent(input$data_select, {
    rv$bld_count <- sansModel:::country_info[input$data_select,'bld_count']
    rv$urb_count <- sansModel:::country_info[input$data_select,'urb_count']
    rv$rur_count <- sansModel:::country_info[input$data_select,'rur_count']
  })
  
  # population total
  observe({
    rv$pop_urb <- rv$urb_count*input$prob_urb*input$units_urb*input$people_urb
    rv$pop_rur <- rv$rur_count*input$prob_rur*input$units_rur*input$people_rur
    
    rv$pop_total <- rv$pop_urb + rv$pop_rur
    
    rv$table <- data.frame(matrix(c(prettyNum(round(rv$pop_total), big.mark=','), 
                                    prettyNum(round(rv$pop_urb), big.mark=','), 
                                    prettyNum(round(rv$pop_rur), big.mark=','), 
                                    prettyNum(round(rv$bld_count), big.mark=','), 
                                    prettyNum(round(rv$urb_count), big.mark=','), 
                                    prettyNum(round(rv$rur_count), big.mark=','), 
                                    prettyNum(round(input$people_urb,1), big.mark=','), 
                                    prettyNum(round(input$units_urb,1), big.mark=','), 
                                    paste0(round(input$prob_urb,1)*100,'%'),
                                    prettyNum(round(input$people_rur,1), big.mark=','), 
                                    prettyNum(round(input$units_rur,1), big.mark=','), 
                                    paste0(round(input$prob_rur*100,1),'%')
                                    ), 
                                  ncol=1),
                           row.names=c('Population Total',
                                       'Population Urban',
                                       'Population Rural',
                                       'Buildings Total',
                                       'Buildings Urban',
                                       'Buildings Rural',
                                       'People per housing unit (urban)',
                                       'Housing units per building (urban)',
                                       'Proportion residential buildings (urban)',
                                       'People per housing unit (rural)',
                                       'Housing units per building (rural)',
                                       'Proportion residential buildings (rural)'
                                       ))
    })
  
  # result table
  output$table <- renderTable(rv$table, 
                              digits = 0,
                              striped = T,
                              colnames = F,
                              rownames = T,
                              format.args = list(big.mark=",", decimal.mark="."))
  
  # download settings button
  output$table_button <- downloadHandler(filename = paste0(input$data_select,'_',format(Sys.time(), "%Y%m%d%H%M"),'.csv'),
                                          content = function(file) {
                                            write.csv(rv$table, file, row.names=T), 
                                            file)
                                          })
  
  # download raster button
  output$raster_button <- downloadHandler(filename = paste0(input$data_select,'_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'),
                                        content = function(file) {
                                          raster::writeRaster(popRaster(country = input$data_select,
                                                                        srcdir = srcdir,
                                                                        prob_urb = input$prob_urb,
                                                                        units_urb = input$units_urb,
                                                                        people_urb = input$people_urb,
                                                                        prob_rur = input$prob_rur,
                                                                        units_rur = input$units_rur,
                                                                        people_rur = input$people_rur
                                                                        ), 
                                                              file)
                                          })
})




