shinyServer(
function(input, output, session){

  options(shiny.maxRequestSize=50*1024^2)
  
  # reactive values
  rv <- reactiveValues()

  # cleanup temporary tifs
  observeEvent(rv$temp_tifs, {
    unlink(rv$temp_tifs)
    unlink(file.path(tempdir(), 'raster'), recursive=T)
    
    shinyjs::enable('raster_buttonBU')
    shinyjs::enable('table_buttonBU')
    shinyjs::enable('source_buttonBU')
    shinyjs::enable('raster_buttonTD')
    shinyjs::enable('source_buttonTD')
  })
  
  ##---- syncronize bottom-up and top-down tabs ----##
  
  # country selection
  observeEvent(input$data_selectBU, {
    rv$data_select <- input$data_selectBU
    updateSelectInput(session, 'data_selectTD', selected=input$data_selectBU)
  })
  
  observeEvent(input$data_selectTD, {
    rv$data_select <- input$data_selectTD
    updateSelectInput(session, 'data_selectBU', selected=input$data_selectTD)
  })
  
  # building area threshold
  observeEvent(input$bld_min_areaBU, {
    rv$bld_min_area <- input$bld_min_areaBU
    updateSliderInput(session, 'bld_min_areaTD', value=input$bld_min_areaBU)
  })
  observeEvent(input$bld_min_areaTD, {
    rv$bld_min_area <- input$bld_min_areaTD
    updateSliderInput(session, 'bld_min_areaBU', value=input$bld_min_areaTD)
  })
  observeEvent(input$bld_max_areaBU, {
    rv$bld_max_area <- input$bld_max_areaBU
    updateSliderInput(session, 'bld_max_areaTD', value=input$bld_max_areaBU)
  })
  observeEvent(input$bld_max_areaTD, {
    rv$bld_max_area <- input$bld_max_areaTD
    updateSliderInput(session, 'bld_max_areaBU', value=input$bld_max_areaTD)
  })
  
  # unit of analysis
  observeEvent(input$units_countBU, {
    rv$units_count <- input$units_countBU
    updateSliderInput(session, 'units_countTD', value=input$units_countBU)
  })
  observeEvent(input$units_countTD, {
    rv$units_count <- input$units_countTD
    updateSliderInput(session, 'units_countBU', value=input$units_countTD)
  })
  
  ##---- load data ----##
  observeEvent(rv$data_select, {

    tryCatch({
      
      # reset reactive values
      for(i in names(rv)[!names(rv) %in% c('data_select','bld_min_area','bld_max_area','units_count')]){
        rv[[i]] <- NULL
      }
      
      # country info
      rv$country_info <- country_info[rv$data_select,]
      
      # country data
      rv$data_full <- readRDS(file.path(srcdir,
                                        paste0(rv$country_info$country,'_dt_Shape_Area_Urb.rds')))
      
      # filter by building area
      rv$data <- rv$data_full[barea >= rv$bld_min_area & barea <= rv$bld_max_area]

      # default reactive values
      rv$urb_count <- sum(rv$data$bld_urban)
      rv$rur_count <- nrow(rv$data) - rv$urb_count

      rv$urb_area <- sum(rv$data[bld_urban==1]$barea) * 0.0001
      rv$rur_area <- sum(rv$data[bld_urban==0]$barea) * 0.0001

      rv$pop_urb <- rv$urb_count * rv$country_info$people_urb * rv$country_info$units_urb * rv$country_info$residential_urb
      rv$pop_rur <- rv$rur_count * rv$country_info$people_rur * rv$country_info$units_rur * rv$country_info$residential_rur
      rv$pop_total <- rv$pop_rur + rv$pop_urb

      # default slider values
      updateSliderInput(session, 'pph_urb', value=rv$country_info$people_urb)
      updateSliderInput(session, 'hpb_urb', value=rv$country_info$units_urb)
      updateSliderInput(session, 'pres_urb', value=rv$country_info$residential_urb)
      updateSliderInput(session, 'ppa_urb', value=rv$pop_urb / rv$urb_area)
      
      updateSliderInput(session, 'pph_rur', value=rv$country_info$people_rur)
      updateSliderInput(session, 'hpb_rur', value=rv$country_info$units_rur)
      updateSliderInput(session, 'pres_rur', value=rv$country_info$residential_rur)
      updateSliderInput(session, 'ppa_rur', value=rv$pop_rur / rv$rur_area)
      
      # paths to source files
      rv$path_buildings_readme <- file.path(srcdir, srcfiles[grepl('README.pdf', srcfiles) & grepl('buildings', srcfiles)][1])
      if(!file.exists(rv$path_buildings_readme)) rv$path_buildings_readme <- NULL
      
      rv$path_agesex_readme <- file.path(srcdir, srcfiles[grepl('README.pdf', srcfiles) & grepl('agesex', srcfiles)][1])
      if(!file.exists(rv$path_agesex_readme)) rv$path_agesex_readme <- NULL
      
      rv$path_urban <- file.path(srcdir, fileNames(rv$country_info$country, srcdir)[['urban']])
      if(!file.exists(rv$path_urban)) stop(paste(rv$country_info$country,'"urban" source file not available.'), call.=F)
      
      rv$path_agesex_regions <- file.path(srcdir,fileNames(rv$country_info$country, srcdir)[['regions']])
      if(!file.exists(rv$path_agesex_regions)) stop(paste(rv$country_info$country,'"regions" source file not available.'), call.=F)
      
      rv$path_agesex_table <- file.path(srcdir,fileNames(rv$country_info$country, srcdir)[['agesex']])
      if(!file.exists(rv$path_agesex_table)) stop(paste(rv$country_info$country,'"agesex" source file not available.'), call.=F)
      
      # popup message
      rv$popup_message <- c()
      
      if(rv$country_info$wopr & rv$country_info$woprVision){
        rv$popup_message[1] <- paste0('There are customized gridded population estimates available for ',rv$data_select,'. These data are available for download from the <a href="https://wopr.worldpop.org/?',rv$data_select,'" target="_blank">WorldPop Open Population Repository (WOPR)</a> and you can explore those results on an interactive map using the <a href="https://apps.worldpop.org/woprVision" target="_blank">woprVision web application</a>.')
      } else if(rv$country_info$wopr) {
        rv$popup_message[1] <- paste0('There are customized gridded population estimates available for ',rv$data_select,'. These data are available for download from the <a href="https://wopr.worldpop.org/?',rv$data_select,'" target="_blank">WorldPop Open Population Repository (WOPR)</a>.')
      }
      if(rv$country_info$partial_footprints){
        rv$popup_message[length(rv$popup_message)+1] <- paste0('Warning: The building footprints for ',rv$data_select,' do not have complete national coverage. Download the source files to see the coverage.')
      }
      if(!is.null(rv$popup_message[1])){
        showModal(modalDialog(HTML(paste(rv$popup_message,collapse='<br><br>')),
                              title='Friendly Message:',
                              footer=tagList(modalButton('Okay, thanks.'))))
      }
      
    }, warning=function(w){
      showNotification(as.character(w), type='warning', duration=20)
    }, 
    error=function(e){
      showNotification(as.character(e), type='error', duration=20)
    }, finally={
      
    })
  })
  
  ##---- building threshold ----##
  observeEvent(c(rv$bld_min_area,rv$bld_max_area), {
    rv$data <- rv$data_full[barea >= rv$bld_min_area & barea <= rv$bld_max_area]
    
    rv$urb_count <- sum(rv$data$bld_urban)
    rv$rur_count <- nrow(rv$data) - rv$urb_count
    
    rv$urb_area <- sum(rv$data[bld_urban==1]$barea) * 0.0001
    rv$rur_area <- sum(rv$data[bld_urban==0]$barea) * 0.0001
  })
    
  ##---- bottom-up ----##
  
  ##---- controls: unit of analysis ----#
  observe({
    shinyjs::toggle('pph_urb', condition=input$units_countBU==T)
    shinyjs::toggle('hpb_urb', condition=input$units_countBU==T)
    shinyjs::toggle('pres_urb', condition=input$units_countBU==T)
    shinyjs::toggle('pph_rur', condition=input$units_countBU==T)
    shinyjs::toggle('hpb_rur', condition=input$units_countBU==T)
    shinyjs::toggle('pres_rur', condition=input$units_countBU==T)
    
    shinyjs::toggle('ppa_urb', condition=input$units_countBU==F)
    shinyjs::toggle('ppa_rur', condition=input$units_countBU==F)
  })
  
  ##---- quick-calculate national population results (bottom-up) ----##
  observe({
    
    if(input$units_countBU){
      rv$pop_urb <- rv$urb_count * input$pph_urb * input$pres_urb * input$hpb_urb
      
      rv$pop_rur <- rv$rur_count * input$pph_rur * input$pres_rur * input$hpb_rur
      
      rv$maxpop_urb <- max(rv$data[bld_urban==1, .N, by=cellID]$N, na.rm=T) *
        input$pres_urb * input$hpb_urb * input$pph_urb
      
      rv$maxpop_rur <- max(rv$data[bld_urban==0, .N, by=cellID]$N, na.rm=T) *
        input$pres_rur * input$hpb_rur * input$pph_rur
      
      updateSliderInput(session, 'ppa_urb',
                        value = rv$pop_urb / rv$urb_area)
      
      updateSliderInput(session, 'ppa_rur',
                        value = rv$pop_rur / rv$rur_area)
      
    } else {
      
      rv$pop_urb <- rv$urb_area * input$ppa_urb
      
      rv$pop_rur <- rv$rur_area * input$ppa_rur
      
      rv$maxpop_urb <- max(rv$data[bld_urban==1, .(A = sum(barea)), by=cellID]$A, na.rm=T) * 0.0001 *
        input$ppa_urb 
      
      rv$maxpop_rur <- max(rv$data[bld_urban==0, .(A = sum(barea)), by=cellID]$A, na.rm=T) * 0.0001 *
        input$ppa_rur 
      
      updateSliderInput(session, 'pres_urb',
                        value = rv$pop_urb / (rv$urb_count * input$pph_urb * input$hpb_urb))
      
      updateSliderInput(session, 'pres_rur',
                        value = rv$pop_rur / (rv$rur_count * input$pph_rur * input$hpb_rur))
    }
    rv$pop_total <- rv$pop_urb + rv$pop_rur
  })
  
  # results table
  observe({
    
    rv$table <- data.frame(settings=matrix(c(prettyNum(round(rv$pop_total), big.mark=','),
                                             prettyNum(round(rv$bld_min_area), big.mark=','),
                                             prettyNum(round(rv$bld_max_area), big.mark=','),
                                             paste0(prettyNum(round(rv$pop_urb/rv$pop_total*100), big.mark=','),'%'),
                                             prettyNum(round(rv$pop_urb), big.mark=','),
                                             prettyNum(round(rv$urb_count), big.mark=','),
                                             prettyNum(round(rv$urb_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_urb/rv$urb_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_urb/rv$urb_count,1), big.mark=','),
                                             prettyNum(round(rv$maxpop_urb), big.mark=','),
                                             prettyNum(round(input$pph_urb,1), big.mark=','),
                                             prettyNum(round(input$hpb_urb,1), big.mark=','),
                                             paste0(round(input$pres_urb*100),'%'),
                                             prettyNum(round(rv$pop_rur), big.mark=','),
                                             prettyNum(round(rv$rur_count), big.mark=','),
                                             prettyNum(round(rv$rur_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_rur/rv$rur_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_rur/rv$rur_count,1), big.mark=','),
                                             prettyNum(round(rv$maxpop_rur), big.mark=','),
                                             prettyNum(round(input$pph_rur,1), big.mark=','),
                                             prettyNum(round(input$hpb_rur,1), big.mark=','),
                                             paste0(round(input$pres_rur*100),'%')
                                             ),
                                           ncol=1),
                           row.names=c('Population Total',
                                       'Min residential building footprint (sq m)',
                                       'Max residential building footprint (sq m)',
                                       '% Urban Population',
                                       'Urban: Population',
                                       'Urban: Building footprints',
                                       'Urban: Building area',
                                       'Urban: People per building hectare',
                                       'Urban: People per building footprint',
                                       'Urban: Max people per 100 m grid cell',
                                       'Urban: People per housing unit',
                                       'Urban: Housing units per building',
                                       'Urban: Proportion residential buildings',
                                       'Rural: Population',
                                       'Rural: Building footprints',
                                       'Rural: Building area',
                                       'Rural: People per building hectare',
                                       'Rural: People per building footprint',
                                       'Rural: Max people per 100 m grid cell',
                                       'Rural: People per housing unit',
                                       'Rural: Housing units per building',
                                       'Rural: Proportion residential buildings'
                                       ))
  })

  # on-screen results table (bottom-up)
  output$table_results <- renderTable(data.frame(rv$table[c('Population Total',
                                                            '% Urban Population',
                                                            'Urban: Population',
                                                            'Rural: Population',
                                                            'Urban: People per building footprint',
                                                            'Rural: People per building footprint',
                                                            'Urban: Max people per 100 m grid cell',
                                                            'Rural: Max people per 100 m grid cell',
                                                            'Urban: Building footprints',
                                                            'Rural: Building footprints'),], 
                                                 row.names=c('Population Total',
                                                             '% Urban Population',
                                                             'Urban: Population',
                                                             'Rural: Population',
                                                             'Urban: People per building footprint',
                                                             'Rural: People per building footprint',
                                                             'Urban: Max people per 100 m grid cell',
                                                             'Rural: Max people per 100 m grid cell',
                                                             'Urban: Building footprints',
                                                             'Rural: Building footprints')),
                                      digits = 0,
                                      striped = T,
                                      colnames = F,
                                      rownames = T,
                                      width = 405,
                                      format.args = list(big.mark=",", decimal.mark="."))

  
  # observe age-sex selection (bottom-up)
  observe({
    
    # format age-sex selection to column names
    rv$agesex_selectBU <- agesexLookup(male = input$male_toggleBU,
                                       female = input$female_toggleBU,
                                       male_select = input$male_selectBU,
                                       female_select = input$female_selectBU)
    
    # syncronize settings in top-down tab
    updateCheckboxInput(session, 'male_toggleTD', value=input$male_toggleBU)
    updateCheckboxInput(session, 'female_toggleTD', value=input$female_toggleBU)
    shinyWidgets::updateSliderTextInput(session, 'male_selectTD', selected=input$male_selectBU)
    shinyWidgets::updateSliderTextInput(session, 'female_selectTD', selected=input$female_selectBU)
  })
  
  ## buttons ##
  
  # download settings button (bottom-up)
  output$table_buttonBU <- downloadHandler(
    filename = function() {
      paste0(rv$data_select,'_settings_',format(Sys.time(), "%Y%m%d%H%M"),'.csv')
    },
    content = function(file) {
      withProgress({
        write.csv(rv$table, file, row.names=T)
      },
      message='Preparing data:',
      detail='Creating .csv spreadsheet with your settings...',
      value=1)
  })
  
  # download raster button (bottom-up)
  output$raster_buttonBU <- downloadHandler(
    filename = function() {
      paste0(rv$data_select,'_population_',format(Sys.time(), "%Y%m%d%H%M"),'.tif')
    },
    content = function(file) {
      withProgress({
        tryCatch(
          withCallingHandlers({
            
            shinyjs::disable('raster_buttonBU')
            shinyjs::disable('table_buttonBU')
            shinyjs::disable('source_buttonBU')
            shinyjs::disable('raster_buttonTD')
            shinyjs::disable('source_buttonTD')
            
            # bottom-up aggregation
            if(input$units_countBU){
              x <- aggregator(buildings = buildingRaster(rv$data, raster::raster(rv$path_urban), 'count'),
                              urban = raster::raster(rv$path_urban),
                              people_urb = input$pph_urb,
                              units_urb = input$hpb_urb,
                              residential_urb = input$pres_urb,
                              people_rur = input$pph_rur,
                              units_rur = input$hpb_rur,
                              residential_rur = input$pres_rur)
            } else {
              x <- aggregator(buildings = buildingRaster(rv$data, raster::raster(rv$path_urban), 'area')*0.0001,
                              urban = raster::raster(rv$path_urban),
                              people_urb = input$ppa_urb,
                              units_urb = 1,
                              residential_urb = 1,
                              people_rur = input$ppa_rur,
                              units_rur = 1,
                              residential_rur = 1)
            }
          
            # age-sex adjustment
            if(length(rv$agesex_selectBU) < 36){
              
              setProgress(value=1, message='Preparing data:', detail='Updating your gridded population estimates to represent the selected age-sex groups...')
              
              x <- demographic(population = x,
                               group_select = rv$agesex_selectBU,
                               regions = raster::raster(rv$path_agesex_regions),
                               proportions = read.csv(rv$path_agesex_table))
            }
            
            # save result
            raster::writeRaster(x = x,
                                filename = file)
            
            rv$temp_tifs <- list.files(tempdir(), full.names=T)[grepl('.tif',list.files(tempdir()))]

          }, warning=function(w){
            showNotification(as.character(w), type='warning', duration=20)
          }), 
          error=function(e){
            showNotification(as.character(e), type='error', duration=20)
          }, finally={
            rm(x);gc()
          })
      },
      message='Preparing data:',
      detail='Creating .tif raster with your gridded population estimates...',
      value=1)
    })
  
  # download source button (bottom-up)
  output$source_buttonBU <- downloadHandler(
    filename = function() paste0(rv$data_select,'_source_',format(Sys.time(), "%Y%m%d%H%M"),'.zip'),
    content = function(file) {
      withProgress({
        
        if(input$units_countBU){
          rv$path_buildings <- file.path(tempdir(), 
                                         paste0(rv$country_info$country,'_building_count_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
          raster::writeRaster(x = buildingRaster(rv$data, raster::raster(rv$path_urban), 'count'),
                              filename = rv$path_buildings)
        } else {
          rv$path_buildings <- file.path(tempdir(),
                                         paste0(rv$country_info$country,'_building_area_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
          raster::writeRaster(x = buildingRaster(rv$data, raster::raster(rv$path_urban), 'area')*0.0001,
                              filename = rv$path_buildings)
        }
        
        rv$source_files <- c(rv$path_buildings,
                             rv$path_urban,
                             rv$path_buildings_readme)
        if(length(rv$agesex_selectBU) < 36) {
          rv$source_files <- c(rv$source_files, rv$path_agesex_regions,
                               rv$path_agesex_table,
                               rv$path_agesex_readme)
        }
        zip::zipr(zipfile = file,
                  files = rv$source_files)
        unlink(rv$path_buildings)
      },
      message='Preparing data:',
      detail='Creating .zip archive with source data...',
      value=1)
    })
  
  ##---- top-down ----##
  
  # observe file upload (top-down)
  observeEvent(input$user_json, {
    if(is.null(input$user_json[,'datapath'])){
      updateSelectInput(session, 'popcol', choices='(no polygons uploaded)')
      shinyjs::disable('raster_buttonTD')
    } else {
      updateSelectInput(session, 'popcol', choices=names(sf::st_read(input$user_json[,'datapath'], quiet=T)))
      shinyjs::enable('raster_buttonTD')
    }
  })  
  
  # observe age-sex selection (top-down)
  observe({
    rv$agesex_selectTD <- agesexLookup(male = input$male_toggleTD,
                                       female = input$female_toggleTD,
                                       male_select = input$male_selectTD,
                                       female_select = input$female_selectTD)
    
    updateCheckboxInput(session, 'male_toggleBU', value=input$male_toggleTD)
    updateCheckboxInput(session, 'female_toggleBU', value=input$female_toggleTD)
    shinyWidgets::updateSliderTextInput(session, 'male_selectBU', selected=input$male_selectTD)
    shinyWidgets::updateSliderTextInput(session, 'female_selectBU', selected=input$female_selectTD)
  })
  
  ## buttons ##

  # download raster button (top-down)
  output$raster_buttonTD <- downloadHandler(
    filename = function() {
      paste0(rv$data_select,'_population_',format(Sys.time(), "%Y%m%d%H%M"),'.tif')
    },
    content = function(file) {
      withProgress({
        tryCatch(
          withCallingHandlers({
            
            if(is.null(input$user_json[,'datapath'])) {
              stop('You must upload a geojson file that contains polygons with the total population of each in a column of the attribute table.', call.=F)
            }
            
            shinyjs::disable('raster_buttonBU')
            shinyjs::disable('table_buttonBU')
            shinyjs::disable('source_buttonBU')
            shinyjs::disable('raster_buttonTD')
            shinyjs::disable('source_buttonTD')
            
            # top-down disaggregation
            x = disaggregator(feature = sf::st_read(input$user_json[,'datapath'], quiet=T), 
                              buildings = buildingRaster(data = rv$data, 
                                                         mastergrid = raster::raster(rv$path_urban), 
                                                         type = ifelse(input$units_countTD,'count','area'))*0.0001,
                              popcol = input$popcol)
            
            # age-sex adjustment
            if(length(rv$agesex_selectBU) < 36){
              
              setProgress(value=1, message='Preparing data:', detail='Updating your gridded population estimates to represent the selected age-sex groups...')
              
              x <- demographic(population = x,
                               group_select = rv$agesex_selectBU,
                               regions = raster::raster(rv$path_agesex_regions),
                               proportions = read.csv(rv$path_agesex_table))
              }
            
            # save result
            raster::writeRaster(x, filename = file)
            
            rv$temp_tifs <- list.files(tempdir(), full.names=T)[grepl('.tif',list.files(tempdir()))]
            
            }, warning=function(w){
              showNotification(as.character(w), type='warning', duration=20)
          }), 
          error=function(e){
            showNotification(as.character(e), type='error', duration=20)
          }, finally={
            shinyjs::reset('user_json')
            rm(x);gc()
          })  
        },
        message='Preparing data:',
        detail='Creating .tif raster with your gridded population estimates...',
        value=1)  
      })
  
  # download source button (top-down)
  output$source_buttonTD <- downloadHandler(
    filename = function() {
      paste0(rv$data_select,'_source_',format(Sys.time(), "%Y%m%d%H%M"),'.zip')
    },
    content = function(file) {
      withProgress({
        
        if(input$units_countTD){
          rv$path_buildings <- file.path(tempdir(), 
                                         paste0(rv$country_info$country,'_building_count_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
          raster::writeRaster(x = buildingRaster(rv$data, raster::raster(rv$path_urban), 'count'),
                              filename = rv$path_buildings)
        } else {
          rv$path_buildings <- file.path(tempdir(),
                                         paste0(rv$country_info$country,'_building_area_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
          raster::writeRaster(x = buildingRaster(rv$data, raster::raster(rv$path_urban), 'area')*0.0001,
                              filename = rv$path_buildings)
        }
        rv$source_files <- c(rv$path_buildings,
                             rv$path_urban,
                             rv$path_buildings_readme)
        if(length(rv$agesex_selectBU) < 36) {
          rv$source_files <- c(rv$source_files, rv$path_agesex_regions,
                               rv$path_agesex_table,
                               rv$path_agesex_readme)
        }
        zip::zipr(zipfile = file,
                  files = rv$source_files)
        unlink(rv$path_buildings)
      },
      message='Preparing data:',
      detail='Creating .zip archive with source data...',
      value=1)
    })
})

