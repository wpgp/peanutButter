shinyServer(
function(input, output, session){

  options(shiny.maxRequestSize=50*1024^2)
  
  # reactive values
  rv <- reactiveValues(bld_min_area=0, bld_max_area=Inf)

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
  
  ##---- load data ----##
  observeEvent(input$data_select, {

    tryCatch({
      
      updateCheckboxInput(session, 'toggleAdvanced', value=F)
      
      # reset reactive values
      for(i in names(rv)[!names(rv) %in% c('toggleAdvanced','units_count','bld_min_area','bld_max_area','agesex_select')]){
        rv[[i]] <- NULL
      }
      
      # reset table
      output$table_results <- NULL
      
      # country info
      rv$country_info <- country_info[input$data_select,]
      
      # check for rds file
      if(file.exists(file.path(srcdir,fileNames(rv$country_info$country, srcdir)[['data']]))){
        shinyjs::show('toggleAdvanced')
      } else {
        shinyjs::hide('toggleAdvanced')
      }
      
      # default reactive values
      rv$urb_count <- rv$country_info$urb_count
      rv$rur_count <- rv$country_info$rur_count
      rv$urb_area <- rv$country_info$urb_area
      rv$rur_area <- rv$country_info$rur_area
      rv$pop_urb <- with(country_info, urb_count * people_urb * units_urb * residential_urb)
      rv$pop_rur <- with(country_info, rur_count * people_rur * units_rur * residential_rur)

      # default slider values
      updateSliderInput(session, 'pph_urb', value=rv$country_info$people_urb)
      updateSliderInput(session, 'hpb_urb', value=rv$country_info$units_urb)
      updateSliderInput(session, 'pres_urb', value=rv$country_info$residential_urb)
      updateSliderInput(session, 'ppa_urb', value=rv$country_info$density_urb)
      
      updateSliderInput(session, 'pph_rur', value=rv$country_info$people_rur)
      updateSliderInput(session, 'hpb_rur', value=rv$country_info$units_rur)
      updateSliderInput(session, 'pres_rur', value=rv$country_info$residential_rur)
      updateSliderInput(session, 'ppa_rur', value=rv$country_info$density_rur)
      
      updateCheckboxInput(session, 'updated', value=T)
      
      # paths to source files
      rv$path_buildings_readme <- file.path(srcdir, srcfiles[grepl('README.pdf', srcfiles) & grepl('buildings', srcfiles)][1])
      if(!file.exists(rv$path_buildings_readme)) rv$path_buildings_readme <- NULL
      
      rv$path_agesex_readme <- file.path(srcdir, srcfiles[grepl('README.pdf', srcfiles) & grepl('agesex', srcfiles)][1])
      if(!file.exists(rv$path_agesex_readme)) rv$path_agesex_readme <- NULL
      
      rv$path_buildings <- file.path(srcdir, fileNames(rv$country_info$country, srcdir)[['count']])
      if(!file.exists(rv$path_buildings)) stop(paste(rv$country_info$country,'"building count" source file not available.'), call.=F)
      
      rv$path_urban <- file.path(srcdir, fileNames(rv$country_info$country, srcdir)[['urban']])
      if(!file.exists(rv$path_urban)) stop(paste(rv$country_info$country,'"urban" source file not available.'), call.=F)
      
      rv$path_year <- file.path(srcdir, fileNames(rv$country_info$country, srcdir)[['year']])
      if(!file.exists(rv$path_year)) warning(paste(rv$country_info$country,'"imagery year" source file not available.'), call.=F)
      
      rv$path_agesex_regions <- file.path(srcdir,fileNames(rv$country_info$country, srcdir)[['regions']])
      if(!file.exists(rv$path_agesex_regions)) stop(paste(rv$country_info$country,'"regions" source file not available.'), call.=F)
      
      rv$path_agesex_table <- file.path(srcdir,fileNames(rv$country_info$country, srcdir)[['agesex']])
      if(!file.exists(rv$path_agesex_table)) stop(paste(rv$country_info$country,'"agesex" source file not available.'), call.=F)
      
      # popup message
      rv$popup_message <- c()
      
      if(rv$country_info$wopr & rv$country_info$woprVision){
        rv$popup_message[1] <- paste0('There are customized gridded population estimates available for ',country_info[input$data_select,'country_name'],' (',input$data_select,'). These data are available for download from the <a href="https://wopr.worldpop.org/?',input$data_select,'" target="_blank">WorldPop Open Population Repository (WOPR)</a> and you can explore those results on an interactive map using the <a href="https://apps.worldpop.org/woprVision" target="_blank">woprVision web application</a>.')
      } else if(rv$country_info$wopr) {
        rv$popup_message[1] <- paste0('There are customized gridded population estimates available for ',country_info[input$data_select,'country_name'],' (',input$data_select,'). These data are available for download from the <a href="https://wopr.worldpop.org/?',input$data_select,'" target="_blank">WorldPop Open Population Repository (WOPR)</a>.')
      }
      if(rv$country_info$partial_footprints){
        rv$popup_message[length(rv$popup_message)+1] <- paste0('Warning: The building footprints for ',country_info[input$data_select,'country_name'],'  (',input$data_select,') do not have complete national coverage. Download the source files to see the coverage.')
      }
      if(!is.null(rv$popup_message[1])){
        showModal(modalDialog(HTML(paste(rv$popup_message,collapse='<br><br>')),
                              title='Friendly Message:',
                              footer=tagList(modalButton('Okay, thanks.'))))
      }
      
    }, warning=function(w){
      
      showNotification(as.character(w), type='warning', duration=20)
      
    }, error=function(e){
      
      showNotification(as.character(e), type='error', duration=20)
      
    }, finally={
      
    })
  })
  
  # year of footprints text
  output$yeartextBU <- renderText({
    paste0('* Building footprints for ', rv$country_info$country_name, ' were based on satellite imagery from 2019 (', round(rv$country_info$year2019*100),'%), 2018 (', round(rv$country_info$year2018*100),'%), 2017 (', round(rv$country_info$year2017*100),'%), 2016 (', round(rv$country_info$year2016*100),'%), 2015 or earlier (', round(rv$country_info$year2015pre*100),'%) (Ecopia.AI, Maxar 2020; <a href="',paste0('https://wopr.worldpop.org/?',rv$country_info$country,'/Buildings'),'" target="_blank">Dooley et al. 2020</a>).<br>',
           '* Default "Population Total" is from ',ifelse(rv$country_info$wopr, 
                                                          paste0('<a href="https://wopr.worldpop.org/?',input$data_select,'" target="_blank">WorldPop Open Population Repository</a>'),
                                                          '<a href="https://data.worldbank.org/indicator/sp.pop.totl" target="_blank">WorldBank (2019)</a>'),
           ', and defaults for "Mean people per housing unit" are from <a href="https://population.un.org/Household/index.html#/countries/728" target="_blank">United Nations (2019)</a> or <a href="https://www.un.org/en/development/desa/population/publications/pdf/ageing/household_size_and_composition_around_the_world_2017_data_booklet.pdf" target="_blank">United Nations (2017)</a>. See "About" tab for more info.')
  })
  
  output$yeartextTD <- renderText({
    paste0('* Building footprints for "', rv$country_info$country_name, '" were based on satellite imagery from 2019 (', round(rv$country_info$year2019*100),'%), 2018 (', round(rv$country_info$year2018*100),'%), 2017 (', round(rv$country_info$year2017*100),'%), 2016 (', round(rv$country_info$year2016*100),'%), 2015 or earlier (', round(rv$country_info$year2015pre*100),'%) (Ecopia.AI, Maxar 2020; <a href="',paste0('https://wopr.worldpop.org/?',rv$country_info$country,'/Buildings'),'" target="_blank">Dooley et al. 2020</a>).')
  })

  # observe slider updates after initializing new country
  observeEvent(input$updated, {
    if(input$updated){
      shinyjs::click('submit')
      updateCheckboxInput(session,'updated',value=F)      
    }
  })
  
  # observe input sliders
  observeEvent(c(input$pph_urb,input$hpb_urb,input$pres_urb,input$ppa_urb,
                 input$pph_rur,input$hpb_rur,input$pres_rur,input$ppa_rur,
                 input$toggleAdvanced, input$units_count,input$bld_min_area,input$bld_max_area), {
    
    shinyjs::runjs('$("#submit").css("box-shadow","0 0 3px #333333")')
    shinyjs::enable('submit')
  })
  
  # toggle advanced
  observeEvent(input$toggleAdvanced, {
    if(input$toggleAdvanced){
      rv$data_full <- readRDS(file.path(srcdir,
                                        paste0(rv$country_info$country,'_dt_Shape_Area_Urb.rds')))
      
      rv$data <- rv$data_full[barea >= rv$bld_min_area & barea <= rv$bld_max_area]
    } else {
      rv$data_full <- rv$data <- NULL
      
      updateSliderInput(session, 'bld_min_area', value=0)
      updateSliderInput(session, 'bld_max_area', value=max_building)
      updateRadioButtons(session, 'units_count', selected=T)
    }
  })
  
  # building threshold
  observeEvent(c(input$bld_min_area,input$bld_max_area), {
    
    rv$bld_max_area <- ifelse(input$bld_max_area==max_building, Inf, input$bld_max_area)
    rv$bld_min_area <- input$bld_min_area
    
    if(rv$bld_min_area==0 & rv$bld_max_area==Inf){
      if(input$toggleAdvanced){
        rv$data <- rv$data_full[barea >= rv$bld_min_area & barea <= rv$bld_max_area]
      }
      rv$urb_count <- rv$country_info$urb_count
      rv$rur_count <- rv$country_info$rur_count
      rv$urb_area <- rv$country_info$urb_area
      rv$rur_area <- rv$country_info$rur_area
      
    } else {
      rv$data <- rv$data_full[barea >= rv$bld_min_area & barea <= rv$bld_max_area]
      
      rv$urb_count <- sum(rv$data$bld_urban)
      rv$rur_count <- nrow(rv$data) - rv$urb_count
      rv$urb_area <- sum(rv$data[bld_urban==1]$barea) * 0.0001
      rv$rur_area <- sum(rv$data[bld_urban==0]$barea) * 0.0001
    }
  })
  
  # show controls for active tab
  observeEvent(input$tabs, {
    if(input$tabs=='Aggregate'){
      shinyjs::show('aggregate_controls1')
      shinyjs::show('aggregate_controls2')
      shinyjs::hide('disaggregate_controls')
    } else if(input$tabs=='Disaggregate'){
      shinyjs::show('disaggregate_controls')
      shinyjs::hide('aggregate_controls1')
      shinyjs::hide('aggregate_controls2')
    }
  })
  
  # observe age-sex selection
  observe({
    
    # format age-sex selection to column names
    rv$agesex_select <- agesexLookup(male = input$male_toggle,
                                     female = input$female_toggle,
                                     male_select = input$male_select,
                                     female_select = input$female_select)
  })
    
  ####---- bottom-up ----####
  
  ##---- controls: unit of analysis ----#
  observeEvent(input$units_count, {
    shinyjs::toggle('pph_urb', condition=input$units_count==T)
    shinyjs::toggle('hpb_urb', condition=input$units_count==T)
    shinyjs::toggle('pres_urb', condition=input$units_count==T)
    shinyjs::toggle('pph_rur', condition=input$units_count==T)
    shinyjs::toggle('hpb_rur', condition=input$units_count==T)
    shinyjs::toggle('pres_rur', condition=input$units_count==T)
    shinyjs::toggle('ppa_urb', condition=input$units_count==F)
    shinyjs::toggle('ppa_rur', condition=input$units_count==F)
    
    if(!all(input$ppa_urb==0, input$ppa_rur==0, input$pph_urb==1, input$pph_rur==1, input$hpb_urb==1, input$hpb_rur==1)){
      if(input$units_count){
        updateSliderInput(session, 'pres_urb',
                          value = (rv$urb_area * input$ppa_urb) / (rv$urb_count * input$pph_urb * input$hpb_urb))
        
        updateSliderInput(session, 'pres_rur',
                          value = (rv$rur_area * input$ppa_rur) / (rv$rur_count * input$pph_rur * input$hpb_rur))
      } else {
        updateSliderInput(session, 'ppa_urb',
                          value = (rv$urb_count * input$pph_urb * input$pres_urb * input$hpb_urb) / rv$urb_area)
        
        updateSliderInput(session, 'ppa_rur',
                          value = (rv$rur_count * input$pph_rur * input$pres_rur * input$hpb_rur) / rv$rur_area)
      }
    }
  })
  

  ##---- quick-calculate national population results (bottom-up) ----##
  observeEvent(input$submit, {
    
    rv$table <- NULL
    
    shinyjs::runjs('$("#submit").css("box-shadow","0 0 0px #333333")')
    shinyjs::disable('submit')
    
    if(input$units_count){
      
      rv$pop_urb <- rv$urb_count * input$pph_urb * input$pres_urb * input$hpb_urb
      
      rv$pop_rur <- rv$rur_count * input$pph_rur * input$pres_rur * input$hpb_rur
      
      if(input$toggleAdvanced){
        rv$maxpop_urb <- max(rv$data[bld_urban==1, .N, by=cellID]$N, na.rm=T) *
          input$pres_urb * input$hpb_urb * input$pph_urb
        
        rv$maxpop_rur <- max(rv$data[bld_urban==0, .N, by=cellID]$N, na.rm=T) *
          input$pres_rur * input$hpb_rur * input$pph_rur
      } else {
        rv$maxpop_urb <- rv$maxpop_rur <- NA
      }
      
    } else {
      
      rv$pop_urb <- rv$urb_area * input$ppa_urb
      
      rv$pop_rur <- rv$rur_area * input$ppa_rur
      
      if(input$toggleAdvanced){
        rv$maxpop_urb <- input$ppa_urb * (0.0001 * max(rv$data[bld_urban==1, .(A = sum(barea)), by=cellID]$A, na.rm=T))
        
        rv$maxpop_rur <- input$ppa_rur * (0.0001 * max(rv$data[bld_urban==0, .(A = sum(barea)), by=cellID]$A, na.rm=T))
      } else {
        rv$maxpop_urb <- rv$maxpop_rur <- NA
      }
    }
    rv$pop_total <- rv$pop_urb + rv$pop_rur
    
    
    rv$table <- data.frame(settings=matrix(c(prettyNum(round(rv$pop_total), big.mark=','),
                                             prettyNum(round(rv$bld_min_area), big.mark=','),
                                             ifelse(is.finite(rv$bld_max_area),
                                                              prettyNum(round(rv$bld_max_area), big.mark=','),
                                                              Inf),
                                             paste0(prettyNum(round(rv$pop_urb/rv$pop_total*100), big.mark=','),'%'),
                                             prettyNum(round(rv$pop_urb), big.mark=','),
                                             prettyNum(round(rv$urb_count), big.mark=','),
                                             prettyNum(round(rv$urb_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_urb/rv$urb_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_urb/rv$urb_count,1), big.mark=','),
                                             ifelse(input$toggleAdvanced, 
                                                    prettyNum(round(rv$maxpop_urb), big.mark=','), 
                                                    NA),
                                             prettyNum(round(input$pph_urb,1), big.mark=','),
                                             prettyNum(round(input$hpb_urb,1), big.mark=','),
                                             paste0(round(input$pres_urb*100),'%'),
                                             prettyNum(round(rv$pop_rur), big.mark=','),
                                             prettyNum(round(rv$rur_count), big.mark=','),
                                             prettyNum(round(rv$rur_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_rur/rv$rur_area,1), big.mark=','),
                                             prettyNum(round(rv$pop_rur/rv$rur_count,1), big.mark=','),
                                             ifelse(input$toggleAdvanced, 
                                                    prettyNum(round(rv$maxpop_rur), big.mark=','), 
                                                    NA),
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
    
    # on-screen results table (bottom-up)
    rv$table_rows <- c('Population Total',
                       '% Urban Population',
                       'Urban: Population',
                       'Rural: Population',
                       'Urban: People per building footprint',
                       'Rural: People per building footprint',
                       'Urban: Building footprints',
                       'Rural: Building footprints')
    
    if(input$toggleAdvanced) rv$table_rows <- c(rv$table_rows,
                                                'Urban: Max people per 100 m grid cell',
                                                'Rural: Max people per 100 m grid cell')
    
    output$table_results <- renderTable(data.frame(rv$table[rv$table_rows,], 
                                                   row.names=rv$table_rows),
                                        digits = 0,
                                        striped = T,
                                        colnames = F,
                                        rownames = T,
                                        width = 405,
                                        format.args = list(big.mark=",", decimal.mark="."))
    
  })

  ## buttons ##
  
  # download settings button (bottom-up)
  output$table_buttonBU <- downloadHandler(
    filename = function() {
      paste0(input$data_select,'_settings_',format(Sys.time(), "%Y%m%d%H%M"),'.csv')
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
      paste0(input$data_select,'_population_',format(Sys.time(), "%Y%m%d%H%M"),'.tif')
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
            if(input$units_count){
              if(any(input$units_count==F, input$bld_min_area>0, input$bld_max_area<max_building)){
                temp_raster <- buildingRaster(rv$data, 
                                                 raster::raster(rv$path_urban), 
                                                 'count')
              } else {
                temp_raster <- raster::raster(rv$path_buildings)
              }
              x <- aggregator(buildings = temp_raster,
                              urban = raster::raster(rv$path_urban),
                              people_urb = input$pph_urb,
                              units_urb = input$hpb_urb,
                              residential_urb = input$pres_urb,
                              people_rur = input$pph_rur,
                              units_rur = input$hpb_rur,
                              residential_rur = input$pres_rur)
              try(rm(temp_raster));gc()
            } else {
              x <- aggregator(buildings = buildingRaster(rv$data, 
                                                         raster::raster(rv$path_urban), 
                                                         'area'),
                              urban = raster::raster(rv$path_urban),
                              people_urb = input$ppa_urb,
                              units_urb = 1,
                              residential_urb = 1,
                              people_rur = input$ppa_rur,
                              units_rur = 1,
                              residential_rur = 1)
            }
          
            # age-sex adjustment
            if(length(rv$agesex_select) < 36){
              setProgress(value=1, message='Preparing data:', detail='Updating your gridded population estimates to represent the selected age-sex groups...')
              
              x <- demographic(population = x,
                               group_select = rv$agesex_select,
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
            try(rm(x)); gc()
          })
      },
      message='Preparing data:',
      detail='Creating .tif raster with your gridded population estimates...',
      value=1)
    })
  
  # download source button (bottom-up)
  output$source_buttonBU <- downloadHandler(
    filename = function() paste0(input$data_select,'_source_',format(Sys.time(), "%Y%m%d%H%M"),'.zip'),
    content = function(file) {
      withProgress({
        
        if(any(input$units_count==F, input$bld_min_area>0, input$bld_max_area<max_building)){
          if(input$units_count){
            temp_path <- file.path(tempdir(), 
                                   paste0(rv$country_info$country,'_building_count_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
            raster::writeRaster(x = buildingRaster(rv$data, 
                                                   raster::raster(rv$path_urban), 
                                                   'count'),
                                filename = temp_path)
            
          } else {
            temp_path <- file.path(tempdir(),
                                   paste0(rv$country_info$country,'_building_area_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
            raster::writeRaster(x = buildingRaster(rv$data, 
                                                   raster::raster(rv$path_urban), 
                                                   'area'),
                                filename = temp_path)
          }
        } else {
          temp_path <- rv$path_buildings
        }
        
        if(length(rv$agesex_select)==36) {
          source_files <- c(temp_path,
                            rv$path_urban,
                            rv$path_year,
                            rv$path_buildings_readme)  
        } else {
          source_files <- c(temp_path,
                            rv$path_urban,
                            rv$path_year,
                            rv$path_buildings_readme, 
                            rv$path_agesex_regions,
                            rv$path_agesex_table,
                            rv$path_agesex_readme)
        }
        
        zip::zipr(zipfile = file,
                  files = source_files)
        
        if(!temp_path == rv$path_buildings) unlink(temp_path)
      },
      message='Preparing data:',
      detail='Creating .zip archive with source data...',
      value=1)
    })
  
  ####---- top-down ----####
  
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
  
  ## buttons ##

  # download raster button (top-down)
  output$raster_buttonTD <- downloadHandler(
    filename = function() {
      paste0(input$data_select,'_population_',format(Sys.time(), "%Y%m%d%H%M"),'.tif')
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
            
            if(any(input$units_count==F, input$bld_min_area>0, input$bld_max_area<max_building)){
              temp_raster <- buildingRaster(rv$data, 
                                            raster::raster(rv$path_urban), 
                                            ifelse(input$units_count,'count','area'))
            } else {
              temp_raster <- raster::raster(rv$path_buildings)
            }
            
            # top-down disaggregation
            x = disaggregator(feature = sf::st_read(input$user_json[,'datapath'], quiet=T), 
                              buildings = temp_raster,
                              popcol = input$popcol)
            
            try(rm(temp_raster));gc()
            
            # age-sex adjustment
            if(length(rv$agesex_select) < 36){
              
              setProgress(value=1, message='Preparing data:', detail='Updating your gridded population estimates to represent the selected age-sex groups...')
              
              x <- demographic(population = x,
                               group_select = rv$agesex_select,
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
            try(rm(x));gc()
          })  
        },
        message='Preparing data:',
        detail='Creating .tif raster with your gridded population estimates...',
        value=1)  
      })
  
  # download source button (top-down)
  output$source_buttonTD <- downloadHandler(
    filename = function() {
      paste0(input$data_select,'_source_',format(Sys.time(), "%Y%m%d%H%M"),'.zip')
    },
    content = function(file) {
      withProgress({
        
        if(any(input$units_count==F, input$bld_min_area>0, input$bld_max_area<max_building)){
          if(input$units_count){
            temp_path <- file.path(tempdir(), 
                                      paste0(rv$country_info$country,'_building_count_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
            raster::writeRaster(x = buildingRaster(rv$data, 
                                                   raster::raster(rv$path_urban), 
                                                   'count'),
                                filename = temp_path)
            
          } else {
            temp_path <- file.path(tempdir(),
                                      paste0(rv$country_info$country,'_building_area_',format(Sys.time(), "%Y%m%d%H%M"),'.tif'))
            raster::writeRaster(x = buildingRaster(rv$data, 
                                                   raster::raster(rv$path_urban), 
                                                   'area'),
                                filename = temp_path)
          }
        } else {
          temp_path <- rv$path_buildings
        }
        
        if(length(rv$agesex_select)==36) {
          source_files <- c(temp_path,
                            rv$path_urban,
                            rv$path_year,
                            rv$path_buildings_readme)
        } else {
          source_files <- c(temp_path,
                            rv$path_urban,
                            rv$path_year,
                            rv$path_buildings_readme, 
                            rv$path_agesex_regions,
                            rv$path_agesex_table,
                            rv$path_agesex_readme)
        }
        
        zip::zipr(zipfile = file,
                  files = rsource_files)
        
        if(!temp_path == rv$path_buildings) unlink(temp_path)
      },
      message='Preparing data:',
      detail='Creating .zip archive with source data...',
      value=1)
    })
})

