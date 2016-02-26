
##
## ui.R
##
## NOAADataVizApp
##
## UI code for the NOAADataViz Shiny App
##

ui <- fluidPage(
    title = "NOAADataViz: NOAA Data Visualization",
    titlePanel(h2(strong("NOAA Storm Data Visualization",style = "color:gray"))),
    hr(),
    br(),
    sidebarLayout(
        sidebarPanel(
            helpText("Use the controls below to visualize NOAA storm data 
                         for the desired time period and region."),
            
            hr(),
            selectInput("selRegion", 
                        label = h5(strong("Select a State")),
                        choices = list("Arizona (AZ)","California (CA)",
                                       "Florida (FL)","Maine (ME)",
                                       "Texas (TX)"),
                        selected = "Percent White"),
            hr(),
            sliderInput("timeRange", 
                        label = h5(strong("Time Period (Year)")),
                        min = 1950, max = 2011, value = c(1999, 2011), sep = ""),
            hr(),
            radioButtons("selImpact", 
                         label = h5(strong("Damage Assessment")),
                         choices = list("Population" = 1, "Economic" = 2), 
                         selected = 1)
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("Plot", plotOutput("tabPlot",width = "100%", height="480px")), 
                tabPanel("Summary", htmlOutput("tabSummary")) 
            )
        )
    )
)

shinyUI(ui)
