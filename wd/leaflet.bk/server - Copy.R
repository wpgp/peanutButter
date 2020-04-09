shinyServer(
  function(input, output, session){
    
    # reactive values
    rv <- reactiveValues()
    shinyjs::disable('save_button')
    
    # load raster
    observeEvent(input$data_select, {
        rv$bldg_raster <- raster::raster(file.path(srcdir,paste0(input$data_select,'_building_count.tif')))
        rv$extent <- rv$bldg_raster@extent
        rv$bldg_count <- country_info[input$data_select,'bldg_count']
    })
    
    # leaflet map
    output$map <- leaflet::renderLeaflet({
        map(rv$extent) 
    })
    
    # building count
    observeEvent(input$bldg_raster, {
        rv$bldg_count <- raster::cellStats(rv$bldg_raster, stat='sum')
    })
    
    # population total
    observe({
        rv$pop_total <- rv$bldg_count * input$prob * input$units * input$people
    })
    
    # update map
    observeEvent(rv$pop_raster, {
        mapProxy(rv$pop_raster)
        shinyjs::enable('build_button')
        shinyjs::enable('save_button')
    })
    
    # result table
    output$table <- renderTable(data.frame(Population_Total=rv$pop_total), 
        digits = 0,
        format.args = list(big.mark=",", decimal.mark="."))
    
    # build raster button
    observeEvent(input$build_button, {
        shinyjs::disable('build_button')
        shinyjs::disable('save_button')
        rv$pop_raster <- rv$bldg_raster*input$prob*input$units*input$people
        print(rv$pop_raster)
    })
    
    # download raster button
    output$save_button <- downloadHandler(filename = paste0(input$data_select,'_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'),
        content = function(file) {
            if(!is.null(rv$pop_raster)){
                raster::writeRaster(rv$pop_raster, file)
            }
        })
})




