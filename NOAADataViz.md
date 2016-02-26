NOAADataViz
========================================================
author: Rashmi Keshava Iyengar
date: Feb 25, 2016
width: 1440
height: 900
font-family: 'Calibri'

<style type="text/css">

body, td {
   font-size: 12px;
}
code.r{
  font-size: 9px;
}
pre {
  font-size: 9px
}
</style>




Overview: NOAA Data Visualization App
========================================================
<br>
This is a brief overview of the NOAADataViz Shiny app hosted here:

[https://rkiyengar.shinyapps.io/NOAADataVizApp](https://rkiyengar.shinyapps.io/NOAADataVizApp)

The app is a tool to visualize data that is part of the **NOAA** storm database. **NOAA** is the U.S. National Oceanic and Atmospheric Administration. It is part of the US Department of Commerce and is focused on the study and monitoring of oceanic and atmospheric weather patterns.

More information about **NOAA** can be found [here](http://www.noaa.gov/).
  
Overview: NOAA Storm Data
========================================================
<br>
The NOAADataViz app uses a subset of the data from the NOAA storm database for its analysis. This database tracks characteristics of major storms and weather events in the United States, including when and where they occur, as well as estimates of any fatalities, injuries, and property damage. This information is captured for the years **1950 - 2011** as part of this database.
  
Additional information can be found at these sources:  
* [Storm Database Documentation](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf)
* [Storm Database FAQ](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf)

Storm Data Analysis
========================================================
<br>
The analysis (and associated visualization) uses information pertaining to fatalities and injuries recorded in the storm database for assessing the impact on the population. Further, it uses the property and crop damage numbers in USD to assess the economic impact. **Note:** Although the original database contains information for all 50 states of the US, the app uses a subset of the database containing information for only these states: **Arizona**, **California**, **Florida**, **Maine** and **Texas**.

Below is a sample of the database used:


```
            BGN_DATE COUNTY COUNTYNAME STATE  EVTYPE FATALITIES INJURIES
1 11/14/1952 0:00:00     25    YAVAPAI    AZ TORNADO          0        0
2   3/4/1954 0:00:00     19       PIMA    AZ TORNADO          0        0
  PROPDMG PROPDMGEXP CROPDMG CROPDMGEXP
1       0          3       0          0
2       0          3       0          0
```

Usage: NOAADataVizApp
========================================================
<br>
The app allows control of the following:  
* **Region** (i.e.: State) for which to visualize
* **Duration** (range in start and end year) for which to visualize 
* **Type of Damage** for which to visualize 
  
Make the appropriate selections and see the output change based on your selections. The **summary** tab provides additional information about the plot.  
  
**NOTE:**  
Depending on the controls selected, the **plot** tab may be empty. Check the summary tab for details.

