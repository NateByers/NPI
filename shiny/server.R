
shinyServer(function(input, output) {
   
  output$map <- renderLeaflet({
    home_infusion %>%
      leaflet() %>%
      addTiles() %>%
      addMarkers(~Longitude, ~Latitude, popup = ~popup)
  })
  
  output$table <- DT::renderDT(
    home_infusion %>% dplyr::select(-popup), options = list(searching = FALSE, lengthChange = FALSE,
                                  pageLength = 100)
  )
  
  output$download <- downloadHandler(
    filename = function() {
      paste0('Home_Infusion_Therapy_Pharmacies_', Sys.Date(), '.csv')
    },
    content = function(con) {
      write.csv(home_infusion %>% dplyr::select(-popup), con, row.names = FALSE)
    }
  )
  
})
