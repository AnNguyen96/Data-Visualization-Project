library(tidyverse)
library(lubridate)
library(readxl)
library(stringr)
library(shiny)
library(shinyWidgets)
library(scales)
library(treemap)
library(slickR)
library(plotly)
library(leaflet)
library(wordcloud2) 
library(heatmaply)
library(highcharter)
library(xts)

######################
airline = read.csv("international_airline_activity.csv")
covid = read.csv("COVID_Cases_2022.csv")

### Distribution & Ranking ###
df_treeMap <- airline[,c("In_Out", "Port_Country", "Port_Region")]
df_treeMap <- df_treeMap %>% group_by(In_Out, Port_Region, Port_Country) %>% summarise(value = n())
options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

df_top_InOut <- airline[,c("In_Out", "International_City", "All_Flights")]
df_top_InOut <- df_top_InOut %>% group_by(In_Out, International_City) %>% summarise(count = sum(All_Flights))
df_top_InOut <- df_top_InOut[order(df_top_InOut$In_Out,-df_top_InOut$count),]
df_top_InOut <- df_top_InOut[(df_top_InOut$In_Out == "I" | df_top_InOut$In_Out == "O") & df_top_InOut$count > 40000, ]

df_airline_wordcloud <- airline[,c("In_Out","Airline")]
df_airline_wordcloud <- df_airline_wordcloud %>% group_by(In_Out, Airline) %>% summarise(count = n())
df_airline_wordcloud <- df_airline_wordcloud[order(-df_airline_wordcloud$count),]


### Evolution ###
df_AusCity <- airline[,c("Australian_City", "All_Flights")]
df_AusCity <- df_AusCity %>% group_by(Australian_City) %>% summarise(flights = n())
df_Aus_Lonlat <- read_excel("AustralianCountry_Latlon.xlsx")
df_AusCity_Latlon <- merge(df_AusCity, df_Aus_Lonlat, by.x=c("Australian_City"), by.y=c("City")) 

df_timeseries_allfilght_seat <- airline[,c("Year","Month_num", "All_Flights", "Max_Seats")]
df_timeseries_allfilght_seat$YearMonth <- as.yearmon(paste(df_timeseries_allfilght_seat$Year, df_timeseries_allfilght_seat$Month_num), "%Y %m")
df_timeseries_allfilght_seat <- df_timeseries_allfilght_seat %>% group_by(YearMonth) %>% 
  summarise(All_Flights = sum(All_Flights), Max_Seats = sum(Max_Seats))

### Covid-19 overview ###
covid$Year <- str_split_fixed(covid$diagnosis_date, "-", 3)[,1]
covid$Month <- str_split_fixed(covid$diagnosis_date, "-", 3)[,2]
covid$Month <- as.integer(covid$Month)

df_covid_view <- covid[,c("Year", "acquired", "diagnosis_date")]
df_covid_view <- df_covid_view %>% group_by(Year, acquired) %>% summarise(total = n())

### Covid-19 impact ###
df_corrAirline <- airline[,c("Year", "Month_num", "All_Flights", "Max_Seats")]
df_corrAirline <- df_corrAirline[df_corrAirline$Year %in% c("2020","2021","2022"),]
df_corrAirline <- df_corrAirline %>% group_by(Year, Month_num) %>% summarise(flights = sum(All_Flights), seats = sum(Max_Seats))

df_corrCovid <- covid %>% group_by(Year, Month) %>% summarise(covid_case = n())

df_correlation <- merge(df_corrAirline, df_corrCovid, by.x=c("Year","Month_num"), by.y=c("Year","Month"))
df_correlation <- df_correlation[with(df_correlation, order(Year, Month_num)),]
df_correlation$YearMonth <- as.yearmon(paste(df_correlation$Year, df_correlation$Month_num), "%Y %m")


###################### UI ######################
ui <- fluidPage(
  tags$style("body {background-color: seashell;}"),
  navbarPage(title = "Australian airline world",
             id = "inTabset",
             tabPanel(title = "Home",
                      titlePanel(h1(p("INTERNATIONAL AIRLINE ACTIVITIES AND THE IMPACT OF THE COVID-19 PANDEMIC",
                                      style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                      br(),
                      
                      
                      fluidRow(
                        column(
                          slickROutput("slickr", width="100%"),
                          width=12
                        )
                      ), br(),br(),br(),br(),br(),
                      hr(style = "height: 2px; width: 10%; color: #333; background-color: #FCB040;"),
                      
                      
                      fluidRow(
                        column(
                          width=12,
                          h1(p("INTRODUCTION",style="font-size: 1em; margin-bottom: 30px; text-align:center; font-family: Copperplate;")),
                          
                          h2(p("\"Join us as we dream bigger, fly further and create a brighter future, together\"",style="color: DodgerBlue; font-style: italic; text-align:center; font-family: Copperplate;"))
                        )
                      ),br(),
                      
                      hr(style = "height: 2px; width: 10%; color: #333; background-color: #FCB040;"),br(),br(),
                      
                      
                      fluidRow(
                        column(
                          width = 2
                        ),
                        column(
                          br(),
                          h2(p("AUSTRALIAN INTERNATIONAL AIRLINES",style="color: Tomato; text-align:center; font-family: Garamond;")),
                          br(),
                          column(
                            12,
                            actionButton('jumpToAirline', 'EXPLORE THE DATA NOW >>'),align = "center", style = "margin-bottom: 10px; margin-top: -10px;"
                          ),
                          
                          p("With over 80 years of international flight experience to destinations all over the world. 
                            During the month, forty-nine international airlines operated scheduled routes to and from Australia, 
                            with many international airports positioned across significant cities.",
                            style="font-size: 20px; margin-left: 50px; margin-right: 20px; text-align: justify;"),
                          p("International aviation in Australia has experienced extraordinary growth, diversification, and affordability. 
                            In the 14 years leading up to June, 2019, it has doubled in size and cut passenger fares in half. 
                            Over 550 international flights are now available daily to and from Australia, serving over 42 million passengers yearly.",
                            style="font-size: 20px; margin-left: 50px; margin-right: 20px; text-align: justify;"),

                          column(
                            12,
                            align="center",
                            a("Click Here To Learn More",href="https://www.9news.com.au/qantas", style ="background-color: white; color: darkblue; border: 1px solid;")
                          ),
                          
                          
                          width=4
                        ), 
                        column(
                          img(src = "airline_home.jpg", height = 450, width = 450, style="display: block; margin-left: auto; margin-right: auto;"),
                          width=4
                        ),
                        column(
                          width = 2
                        )
                      ), br(),
                      
                      hr(style = "height: 1.5px; width: 65%; color: #333; background-color: #FCB040;"),br(),br(),
                      
                      
                      fluidRow(
                        column(
                          width = 2
                        ),
                        column(
                          br(),
                          img(src = "covid_home.jpg", height = 450, width = 450, style="display: block; margin-left: auto; margin-right: auto;"),
                          width=4
                        ),
                        column(
                          h2(p("THE IMPACT OF COVID-19",style="color: Tomato; text-align:center; font-family: Garamond;")),
                          br(),
                          column(
                            12,
                            actionButton('jumpToCovid', 'EXPLORE THE DATA NOW >>'),align = "center", style = "margin-bottom: 10px; margin-top: -10px; "
                          ),
                          
                          p("the Covid-19 pandemic has seriously impacted to the economy, travel and businesess across countries. 
                          Under such curcumstance, many countries inplemented targeted policies to prevent the spread of the disease, 
                          including national lock-down, inbound quarantine, international flights suspension and entry ban to affected area. 
                          These strict restriction policies have greatly influenced the international air transportation industry. 
                          Many countries largely reduced their international flights, and some airlines unexpectedly went bankrupt during the pandemic.
                          Some specific numbers are as follows:",
                            style="font-size: 20px; margin-left: 20px; margin-right: 20px; text-align: justify;"),
                          tags$ul(
                            tags$li("In February 2021, passenger traffic was 51.613 million, compare with 2.805 million in February 2020 and 3.257 million in February 2019.", 
                                    style="font-size: 20px; margin-left: 20px; margin-right: 20px; text-align: justify;"),
                            tags$li("For the fiscal year ending February 2022, passenger traffic was 2.315 million, down 6.0 percent from the previous year's number (2.462 million).", 
                                    style="font-size: 20px; margin-left: 20px; margin-right: 20px; text-align: justify;"),
                          ),
                          
                          column(
                            12,
                            align="center",
                            a("Click Here To Learn More",href="https://www.accc.gov.au/media-release/covid-restrictions-bring-domestic-airline-industry-to-a-standstill", style ="background-color: white; color: darkblue; border: 1px solid;")
                          ),
                          
                          width=4
                        ),
                        column(
                          width = 2
                        )
                      ), br(),
                      
                      hr(style = "height: 1.5px; width: 65%; color: #333; background-color: #FCB040;"),br(),
                      
                      fluidRow(
                        column(
                          width = 2
                        ),
                        column(
                          h2(p("ABOUT US",style="color: Tomato; text-align:center; font-family: Garamond;")),
                          p("This project made by NGUYEN PHUC AN",
                            style="font-size: 20px; vertical-align: middle; text-align: center;"),
                          p("Master of Data Science at Monash University",
                            style="font-size: 20px; vertical-align: middle; text-align: center;"),
                          p("FIT5147 Data Exploration and Visualisation Semester 1, 2022",
                            style="font-size: 20px; vertical-align: middle; text-align: center;"),
                          p("14 May 2021",
                            style="font-size: 16px; vertical-align: middle; text-align: center;"),
                          width=8
                        ),
                        column(
                          width=2)
                        ),
                      br(),br()
                      
                      ),
             
             tabPanel(title = "International Airline",
                      value = "panel1",
                      
                      tabsetPanel(
                        type = "tabs",
                        tabPanel(
                          "Distribution & Ranking",
                          br(),
                          
                          sidebarPanel(
                            h2(p("Welcome to International flights exploration",
                                 style="color: DodgerBlue; font-style: italic; text-align:center; font-family: Copperplate;")),
                            br(),
                            
                            column(
                              12,
                              align="center",
                              a("WHERE YOU CAN FIND DATA SOURCE",href="https://www.data.gov.au/data/dataset/international-airlines-operated-flights-and-seats", 
                                style ="margin-bottom: 10px; margin-top: -10px; background-color: white; color: darkblue; border: 1px solid;")
                            ),
                            br(),
                            
                            h4(p("In this tab you will be able to answer the following questions:", 
                                 style="font-size: 20px; font-family: Copperplate;")),
                            tags$ul(
                              tags$li("How many different airlines are used and which airlines are most popular? (Wordcloud)", 
                                      style="font-size: 20px; font-family: Copperplate; text-align: justify;"),
                              tags$li("Which countries do Australians usually travel to and which states/cities in Australia attract more visitors? (Barchart)", 
                                      style="font-size: 20px; font-family: Copperplate; text-align: justify;"),
                              tags$li("Which ports do these airlines' flights belong to, and which regions are those countries located in? (Treemap)", 
                                      style="font-size: 20px; font-family: Copperplate; text-align: justify;"),
                            ),
                            p("All charts are filtered towards to Australia, from Australia or both, 
                              depending on which option you choose below, you can also manipulate directly on the chart itself.
                              Let's experience it!",
                              style="font-size: 20px; font-family: Copperplate;text-align: justify;"),
                            br(),
                            pickerInput(
                              "inOutPicker", "Choose from (O) Australia or to (I) Australia:",
                              choices = c("I", 
                                          "O"),
                              selected = "I",
                              multiple = T
                            ),
                            
                            br(),
                            titlePanel(h2(p("International Airlines",
                                            style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                            wordcloud2Output("airlineWordCloud")
                          ),
                          
                          mainPanel(
                            fluidRow(
                              column(
                                titlePanel(h2(p("Top 10 international cities Australians go to and cities in Australia attract more visitors",
                                                style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                                plotlyOutput("topInternationalCity", height = 600),
                                width = 12
                              )
                            ),
                            br(),br(),br(),
                            fluidRow(
                              column(
                                titlePanel(h2(p("Port countries grouped by port area",
                                                style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                                plotOutput("portTreeMap"),
                                width = 12
                              )
                            ),
                            br(),br(),br()
                          )
                        ),
                        
                        tabPanel(
                          "Evolution",
                          br(),
                          
                          fluidRow(
                            column(
                              br(), br(), br(), br(),
                              h1(p("Map of international flight distribution",
                                   style="color: DodgerBlue; font-style: italic; text-align:center; font-family: Copperplate; padding-left: 20px;")),
                              br(),
                              h4(p("In this tab you will be able to answer the following questions: 
                                   Which Australian city has the most flights to and attracts the most tourists in the past 20 years?
                                   The things you can observe and manipulate are:", 
                                   style="font-size: 22px; font-family: Copperplate; text-align: justify; padding-left: 25px;")),
                              tags$ul(
                                tags$li("Each location will be pre-affixed with a flag marking the location of that city, 
                                        with the radius of each node being the number of their international flights.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;"),
                                tags$li("You can move or zoom in / out on any area of the map to see details.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;"),
                                tags$li("The range slider helps you select a range based on the number of flights, then the
                                        map will be based on the data you selects from the slider and changes the city location on the map.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;"),
                                tags$li("Clicking on the symbol to point to the tooltip displays the name of the city
                                        and the number of international flights recorded there.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;"),
                                
                              ),
                              
                              width=4
                            ), 
                            
                            column(
                              fluidRow(
                                column(12,
                                 titlePanel(h2(p("Total number of flights recorded in key Australian cities",
                                                 style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                                 sliderInput("range", h3("The total number of flight"),
                                             min(df_AusCity_Latlon$flights),
                                             max(df_AusCity_Latlon$flights),
                                             value = range(df_AusCity_Latlon$flights), step = 10),
                                 align="center"
                                )
                              ),
                              fluidRow(
                                column(12,
                                   leafletOutput("dotMapFlight", width = "100%", height = "600px"),
                                   style="padding-right: 85px; padding-left: 25px;"
                                )
                              ),
                              br(),br(),
                              
                              width=8
                            )
                          ),
                          
                          hr(style = "height: 1.5px; width: 15%; color: #333; background-color: #FCB040;"),br(),
                          
                          fluidRow(
                            column(width = 1),
                            column(
                              titlePanel(h2(p("The development of international flight Australia 2003 - 2022",
                                              style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                               plotlyOutput("lineFlight", width = "100%", height = "600px"),
                               width=6
                            ),
                            column(width = 1),
                            br(),br(),
                            
                            column(
                              h1(p("Time series rangeslider in Australia international flights",
                                   style="color: DodgerBlue; font-style: italic; text-align:center; font-family: Copperplate;")),
                              p("How has the number of flights changed in the nearly 20 years to today (2003-2022)? 
                                This line chart will show everyone the most concise  and easy to understand answer.
                                The things you can observe and manipulate are:",
                                style="font-size: 22px; margin-left: 10px; margin-right: 5px; text-align: justify; font-family: Copperplate;"),
                              tags$ul(
                                tags$li("At any position of the line, when you moves in, it will display the year and number of flights at that time.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;"),
                                tags$li("Below the x-axis there will be a rangeslider where you can slide to select the time period you wants to see details.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;"),
                                tags$li("The line chart also has some features like download plot as a png, zoom in, zoom out, pan, box select, autoscale, reset axes, etc.", 
                                        style="font-size: 22px; font-family: Copperplate; text-align: justify;")
                              ),
                              p("Did you spot something out of the ordinary about a trend that's been going well until early 2020. 
                                An event has taken place and directly impacted flights. Stay tuned for the story!",
                                style="font-size: 22px; margin-left: 10px; margin-right: 5px; text-align: justify; font-family: Copperplate;"),
                              width=4
                            )
                          ),
                          
                          br(),br(),
                        )
                      ),
                      ),
             
             tabPanel(title = "Covid-19's Impact",
                      value = "panel2",
                      
                      tabsetPanel(
                        type = "tabs",
                        tabPanel(
                          "Covid-19 overview",
                          
                          br(),
                          
                          sidebarPanel(
                            h2(p("Welcome to Covid-19 pandemic exploration",
                                 style="color: DodgerBlue; font-style: italic; text-align:center; font-family: Copperplate;")),
                            br(),
                            
                            column(
                              12,
                              align="center",
                              a("WHERE YOU CAN FIND DATA SOURCE",href="https://discover.data.vic.gov.au/dataset/all-victorian-sars-cov-2-cases-by-local-government-area-postcode-and-acquired-source", 
                                style ="margin-bottom: 10px; margin-top: -10px; background-color: white; color: darkblue; border: 1px solid;")
                            ),
                            br(),br(),
                            
                            p("In recent years, the Covid-19 pandemic has seriously impacted to the economy, travel and
                              businesess across countries. Under such curcumstance, many countries inplemented targeted
                              policies to prevent the spread of the disease, including national lock-down, inbound quarantine,
                              international flights suspension and entry ban to affected area. These strict restriction policies have
                              greatly influenced the international air transportation industry.",
                              style="font-size: 20px; font-family: Copperplate; text-align: justify;"),
                            
                            p("The chart is divided into many reasons for recording, you can change the drop-down list options or 
                              can select multiple reasons at the same time. Feel free to change it and leave a comment for yourself!",
                              style="font-size: 20px; font-family: Copperplate; text-align: justify;"),
                            br(),
                            
                            pickerInput(
                              "reasonCovidPicker", "Choose recorded reasons:",
                              choices = c("Acquired in Australia, unknown source", 
                                          "Contact with a confirmed case",
                                          "Travel overseas",
                                          "Under investigation"),
                              selected = "Acquired in Australia, unknown source",
                              multiple = T
                            )
                            
                            
                          ),
                          
                          mainPanel(
                            titlePanel(h2(p("The number of COVID-19 cases in different acquired reasons 2020-2022",
                                            style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                            plotlyOutput("covidOverview", height = "800px")
                          )
                          
                        ),
                        tabPanel(
                          "Covid-19 impact",
                          br(),
                          
                          fluidRow(
                            column(
                              h2(p("Trends in the number of international flights and the number of covid cases and their correlation",
                                   style="color: DodgerBlue; font-style: italic; text-align:center; font-family: Copperplate;")),
                              p("You can see an overview of the change in the number of international flights in Australia and the number of covid-19 cases from the beginning of 2020 to the beginning of 2022. 
                                Through combination chart between line chart and bar chart, when moving into each column or line, detailed information will appear. 
                                And you can also partly answer the question yourself: What are the negative impacts of the entry restriction policy on international aviation activities during the COVID-19 pandemic.",
                                style="font-size: 22px; margin-left: 50px; margin-right: 20px; text-align: justify; font-family: Copperplate;"),
                              
                              p("A heat map below will be generated to see the correlation between the variables: number
                                of international flights, number of seats and number of covids based on the display color, the
                                closer to red, the more positively correlated they are, vice versa, the closer to blue, the more
                                negatively correlated they are. When moving the mouse over these areas, we will see the two
                                variables that they are considering the correlation and how much the detailed correlation value is.",
                                style="font-size: 22px; margin-left: 50px; margin-right: 20px; text-align: justify; font-family: Copperplate;"),
                              
                              br(),
                              
                              titlePanel(h2(p("Correlation between variables",
                                              style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                              plotlyOutput("heatmap"), 
                              br(),
                              
                              width=4
                            ), 
                            
                            column(
                              fluidRow(
                                column(12,
                                   titlePanel(h2(p("Trend of total number of flights and covid cases from 2020 to 2022",
                                                   style="font-weight: bold; text-align:center; font-size: 1em; font-family: flix; color: Tomato"))),
                                   plotlyOutput("covidImpact", height = "800px")
                                )
                              ),
                              br(),br(),
                              
                              width=8
                            )
                          )
                          
                        
                          
                        )
                      ))
  )
)

server <- function(input, output, session){
  
  #############################################################################
  # Home                                                                      #
  #############################################################################
  
  output$slickr <- renderSlickR({
    imgs <- list.files("www/cover_img/", pattern=".jpg", full.names = TRUE)
    slick <- slickR(imgs)
    slick + settings(autoplay = TRUE, autoplaySpeed = 3000)
  })

  observeEvent(input$jumpToAirline, {
    updateTabsetPanel(session, "inTabset",
                      selected = "panel1")
  })
  
  observeEvent(input$jumpToCovid, {
    updateTabsetPanel(session, "inTabset",
                      selected = "panel2")
  })
  
  
  #############################################################################
  # Distribution & Ranking                                                    #
  #############################################################################

  output$topInternationalCity <- renderPlotly({
    
    data <- reactive({
      req(input$inOutPicker)
      df_top_InOut <- df_top_InOut %>% filter(In_Out %in% input$inOutPicker)
    })
    
    p <- ggplot(data(), aes(International_City, count, fill = In_Out)) + 
      geom_bar(stat="identity",  width=0.7) +
      scale_fill_brewer(palette = "Set2") +
      coord_flip() +
      ylab("Number of Flight") +
      xlab("International City") +
      # ggtitle("Top 10 international cities do Australians usually travel to \nand cities in Australia attract more visitors") +
      theme_minimal() +
      theme(plot.title = element_text(size = 16, hjust = 0.5), 
            text = element_text(size = 14), 
            axis.text.x = element_text(size = 13), 
            legend.direction = "vertical")+
      geom_text(aes(label=count), position=position_dodge(width=0.9), size = 4)
    
    
    ggplotly(p) %>% layout(hoverlabel=list(bgcolor="white"))
    
    
  })
  
  output$portTreeMap <- renderPlot({

    data <- reactive({
      req(input$inOutPicker)
      df_treeMap <- df_treeMap %>% filter(In_Out %in% input$inOutPicker)
    })
    
    treemap(data(), index=c("Port_Region","Port_Country"),
            vSize="value",
            type="index",

            title=" ",
            fontsize.title=16,
            palette = "Set2",
            vSize,

            fontsize.labels=c(18,10),
            fontcolor.labels=c("white","black"),
            fontface.labels=c(2,1),
            bg.labels=c("transparent"),
            align.labels=list(
              c("center", "center"),
              c("left", "bottom")
            ),
            overlap.labels=0.5,
            inflate.labels=F
    )
  })
  
  output$airlineWordCloud <- renderWordcloud2({
    data <- reactive({
      req(input$inOutPicker)
      df_airline_wordcloud <- df_airline_wordcloud %>% filter(In_Out %in% input$inOutPicker)
    })
    wordcloud2(data()[c(2,3)], size = 2.3, minRotation = -pi/6, maxRotation = -pi/6, rotateRatio = 1)
  })
  
  #############################################################################
  # Evolution                                                                 #
  #############################################################################
  
  filtered <- reactive({
    df_AusCity_Latlon %>%
      filter(flights >= input$range[1],
             flights <= input$range[2]
      )
  })
  
  output$dotMapFlight <- renderLeaflet({
    
    leaflet(filtered()) %>% addTiles() %>% 
      addCircleMarkers(
        radius = (filtered()$flights)/300,
        stroke = FALSE, fillOpacity = 0.5
      ) %>%
      addMarkers (~Longitude, 
                  ~Latitude, 
                  popup = paste("City: ",filtered()$Australian_City, "<br>The total number of flights: ", filtered()$flights)
      )
  })
  
  output$lineFlight <- renderPlotly({
    fig <- plot_ly(df_timeseries_allfilght_seat, type = 'scatter', mode = 'line') %>% 
      add_trace(x = ~YearMonth, y = ~All_Flights) %>%
      layout(showlegend = F, 
             # title = "Time Series with Rangeslider",
             xaxis = list(rangeslider = list(visible = T)
                          ))

    fig <- fig %>%
      layout(
        xaxis = list(zerolinecolor = '#ffff',
                     zerolinewidth = 2,
                     gridcolor = 'ffff'),
        yaxis = list(zerolinecolor = '#ffff',
                     zerolinewidth = 2,
                     gridcolor = 'ffff'),
        plot_bgcolor='#e5ecf6', margin = 0.1, width = 900)


    fig
  })
  
  
  #############################################################################
  # Covid-19 overview                                                         #
  #############################################################################
  
  output$covidOverview <- renderPlotly({
    
    data <- reactive({
      req(input$reasonCovidPicker)
      df_covid_view <- df_covid_view %>% filter(acquired %in% input$reasonCovidPicker)
    })
    
    p <- ggplot(data(), aes(Year, total, fill = acquired)) + 
      geom_bar(stat="identity",  width=0.7, col = "orange") +
      scale_fill_brewer(palette = "Set2") +
      ylab("Number of Covid-19 cases") +
      xlab("Year") +
      # ggtitle("The number of COVID-19 cases in different acquired reasons 2020-2022") +
      theme_minimal() +
      theme(plot.title = element_text(size = 16, hjust = 0.5), 
            text = element_text(size = 14), 
            axis.text.x = element_text(size = 13), 
            legend.direction = "vertical")+
      geom_text(aes(label=total), position=position_dodge(width=0.9), size = 5)

    
    ggplotly(p) %>% layout(hoverlabel=list(bgcolor="white"))
  })
  
  
  #############################################################################
  # Covid-19 impact                                                           #
  #############################################################################
  
  output$covidImpact <- renderPlotly({
    
    
    p <- ggplot(df_correlation, aes(x=YearMonth)) +
      geom_bar(aes(y=200*flights, fill="flights"),stat="identity" ,colour="darkblue")+
      geom_line(aes(y=10*covid_case, color="covid cases"), size=2, alpha=0.9) +
      
      # ggtitle("Trend of total number of flights and covid cases from 2020 to 2022")+
      ylab("Total number of flights") +
      theme_minimal()+
      
      theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +

      scale_fill_manual("",values= c("flights" = "#008970"))+
      scale_colour_manual("", values = c("covid cases" = "#e54b22"))

    ggplotly(p) 
  })
  
  output$heatmap <- renderPlotly({
    df_correlation <- select(df_correlation, -c(Year, Month_num, YearMonth))
    heatmaply_cor(
      cor(df_correlation),
      xlab = "Features", 
      ylab = "Features",
      k_col = 3, 
      k_row = 3
    )
  })
  
}

shinyApp(ui, server)