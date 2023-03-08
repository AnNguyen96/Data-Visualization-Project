<h1 align="center">
  International airline activities and <br>
  the impact of the covid-19 pandemic
</h1>

**Project Description**: This project is part of an assignment in the Data Exploration and Visualization course at Monash University. In this narrative visualisation, I want to convey the story of international flights in Australia from 2003 to present in 2022 and the impact of the covid-19 pandemic in recent years so that viewers can have a better understanding through animated and interactive charts. Dataset is open data collected from [link1](https://www.data.gov.au/data/dataset/international-airlines-operated-flights-and-seats) and [link2](https://discover.data.vic.gov.au/dataset/all-victorian-sars-cov-2-cases-by-local-government-areapostcode-and-acquired-source). The limitation of this project is that it can only be run locally but this will be fixed in the future.

<h4 align="center">The project is made by Phuc An Nguyen</h4>

| | | |
|:-------------------------:|:-------------------------:|:-------------------------:|
|<img width="1604" src="picture/Title.png">  title Homepage |  <img width="1604" src="picture/Info_Homepage.png"> Introduction|<img width="1604" src="picture/Tab1.1.png"> 1st tab|
|<img width="1604" src="picture/Tab1.2.png">  2nd tab |  <img width="1604" src="picture/Tab2.1.png"> 3rd tab |<img width="1604" src="picture/Tab2.2.png"> 4th tab|


## Key Features

* View information, links to respective websites
* Interaction design
  - Drop-down list (Filtering)
  - Slider
  - Mouse-over and tooltip in Map

## How to Run the Project
Run the `app.R` file on `RStudio` to start the website

## How To Use
The web application is separated into three primary tabs: Home, International Airline, and Covid-19's Impact, in order to be intuitive, easy to grasp, and orderly for data storytelling. The tracking will be done in the following order: top to bottom and left to right.

- **Home tab**: 
When scrolling down the web page, viewers will see short pieces of information to introduce Australian International Airline and Covid-19 Impact, with below is a link labeled "Click Here To Learn More", when users clicks will take them to an external web page, at the bottom of the title there will be a tab switch with the label “EXPLORE THE DATA NOW”, depending on where the user clicks, it will move the tab to the Airline or Coivd-19 tab, or to the top of the page web will be the bar to switch between 3 tabs together, users can use them here.

* **International Airline tab**: 
  - **Distribution & Ranking tab**: **Wordcloud** shows which airline names are used a lot depending on the size of the displayed text. When scrolling to the location of each airline, will appear detailed information about how many times that airline has been used. **TreeMap** represents the port country grouped by group region with different colors, in each region the countries will be colored from dark to light depending on the value from high to low. **Barchart** shows the top 10 international cities with the most flights to or from Australia. Especially, because it is designed from 'plotly' method, for this chart, users will have more options of features such as: 
    - Download plot as a png, 
    - Zoom In / Zoom Out, 
    - Pan – Move the chart arbitrarily within the frame, 
    - Box select – Select the data in the box to pay attention, 
    - Autoscale, 
    - Reset axes.
  - **Evolution tab**: **Map** shows the total number of international flights operated from 2003 to 2022 in key Australian cities. User can:
    - Zoom In / Zoom Out, 
    - The range slider: select a range based on the number of flights,
    - Tooltip displays the name of the city and the number of international flights. 
    
    The **line chart** shows the number of international flights changing over time (time series), at any position of the line, when the user moves in:
    - Display the year and number of flights at that time, 
    - Range slider: slide to select the time period user wants to see details.

* **Coivd-19 Impact tab**:
  - **Covid-19 overview tab**: When changing the recording reason filter, the **bar chart** will change shape according to the data. In particular, users can select multiple reasons at the same time, this time the chart will change from bar chart to stacked barchart with different colors to distinguish different reasons.
  - **Covid-19 impact tab**: Through **combination chart** between line chart and bar chart, when moving into each column or line, detailed information will appear. A **heat map** will be generated to see the correlation between the variables: number of international flights, number of seats and number of covids based on the display color. When moving the mouse over these areas, we will see the two variables that they are considering the correlation and how much the detailed correlation value is.

## Credits

This software uses the following open source packages:

- [R](https://cran.r-project.org/bin/windows/base/)
- [tidyverse](https://www.tidyverse.org/)
- [lubridate](https://lubridate.tidyverse.org/)
- [plotly](https://plotly.com/r/)
- [RShiny](https://shiny.rstudio.com/)
- [RStudio](https://posit.co/download/rstudio-desktop/)



