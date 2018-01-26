
shinyUI(fluidPage(
  
  fluidRow(
    leafletOutput("map", height = 600),
    HTML("<center><h2>Home Infusion Therapy Pharmacies</h2></center>"),
    downloadButton('download')
  ),
  
  fluidRow(
    DT::DTOutput("table")
  )

))
