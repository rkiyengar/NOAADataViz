##
## server.R
##
## NOAADataVizApp
##
## Operational code for the NOAADataViz Shiny App
##

# DEPENDENCIES
suppressPackageStartupMessages(require(R.utils,quietly = TRUE))
suppressPackageStartupMessages(require(car,quietly = TRUE))
suppressPackageStartupMessages(require(gsubfn,quietly = TRUE))

# load the data and carry out any transformations
csvFile <- "data/noaa_storm_data_sample.csv"
stormData <<- read.csv(csvFile,stringsAsFactors = FALSE)
stormData$YEAR <- as.POSIXlt(stormData$BGN_DATE,format="%m/%d/%Y %H:%M:%S")$year + 1900

# function to collect & compute information related to population damage
# sum up the fatalities and injuries seperately for each group
popImpact <- function(x)
{
    c(sum(x$FATALITIES,na.rm=TRUE),sum(x$INJURIES,na.rm = TRUE))
}

# function to collect & compute information related to economic damage
# convert property and crop damages to their absolute amounts by multiplying them by 
# the appropriate powers (as given by the exponents) and sum them up seperately
# for each group
finImpact <- function(x)
{
    c(sum((as.numeric(x$PROPDMG) * (10^as.numeric(x$PROPDMGEXP))),na.rm=TRUE)/1000000,
      sum((as.numeric(x$CROPDMG) * (10^as.numeric(x$CROPDMGEXP))),na.rm =TRUE)/1000000)
}


## FUNCTION DEFINITIONS
noaaPlot <- function(input)
{
    startYear <- input$timeRange[1]
    endYear <- input$timeRange[2]
    
    state <- strapplyc(input$selRegion,"^[A-Za-z]+ \\((.*)\\)",simplify=T)
 
    
    #subset the data for the specified state
    stormData.target <- stormData[ (stormData$STATE == state) &
                                   (stormData$YEAR >= startYear) &
                                   (stormData$YEAR <= endYear),]
    
    if(nrow(stormData.target) == 0)
    {
        plot.new()
        return
    }
    else
    {
        # group by event type
        stormData.evt <- split(stormData.target,as.factor(stormData.target$EVTYPE))
    
        if(input$selImpact == 1)
        {
            stormData.evt.pop <- as.data.frame(do.call(rbind, 
                                                       sapply(stormData.evt,
                                                              popImpact,simplify=FALSE)))
            
            names(stormData.evt.pop) <- c("FATALITIES","INJURIES")
            
            # order the weather events by number of fatalities first, then by number of 
            # injuries in the descending order
            order.fi <- order(stormData.evt.pop$FATALITIES,
                              stormData.evt.pop$INJURIES,decreasing = TRUE)
            stormData.evt.pop.ordered.fi <- stormData.evt.pop[order.fi,]
            
            # remove events that have zero fatalities
            stormData.evt.pop.ordered.fi <- stormData.evt.pop.ordered.fi[stormData.evt.pop.ordered.fi$FATALITIES > 0, ]   
            
            n <- if(nrow(stormData.evt.pop.ordered.fi) >= 10) 10 else nrow(stormData.evt.pop.ordered.fi)
            
            if(n > 0)
            {
                main.lab <- paste(state,": Total Fatalities by Event (",
                                  startYear," - ",endYear,")",sep = "") 
                
                par(mar=c(9,5,4,2))
                
                # construct a bar plot for the top ten most harmful events in terms of their 
                # impact on the population (i.e.: fatalities and injuries)
                p.x1 <- barplot(stormData.evt.pop.ordered.fi$FATALITIES[1:n],
                                names.arg="",
                                xlab="",
                                ylab="Total",
                                main = "",
                                ylim=c(0,1.1 * max(stormData.evt.pop.ordered.fi$FATALITIES[1:n])),
                                xlim=c(0,n+1), 
                                width=.5, space = 1,
                                cex.names=0.7,las=2,
                                col="deepskyblue4",
                                border=NA,
                                font.lab=2,
                                font.axis=1)
                
                title(main = main.lab,col.main ="gray20")
                
                axis(side = 1,
                     labels = row.names(stormData.evt.pop.ordered.fi)[1:n],
                     at = p.x1,
                     lty = 0,
                     cex.axis = 0.8,las=2,
                     font = 2)
                
                # add exact nos for each value atop each bar
                text(x = p.x1, y = stormData.evt.pop.ordered.fi$FATALITIES[1:n], 
                     label = stormData.evt.pop.ordered.fi$FATALITIES[1:n],
                     pos = 3, cex = 0.8, col = "red")
                
                p <- recordPlot()
            }
            else
            {
                
                p <- plot.new()
            }
        }
        else
        {
            stormData.evt.fin <- as.data.frame(do.call(rbind,
                                                       sapply(stormData.evt,finImpact,
                                                              simplify = FALSE)))
            names(stormData.evt.fin) <- c("PROPDMG","CROPDMG")
            
            stormData.evt.fin$TOTALDMG <- stormData.evt.fin$PROPDMG + stormData.evt.fin$CROPDMG
            
            order.pc <- order(stormData.evt.fin$TOTALDMG, 
                              stormData.evt.fin$PROPDMG,
                              stormData.evt.fin$CROPDMG,decreasing = TRUE)
            
            stormData.evt.fin.ordered <- stormData.evt.fin[order.pc,]
            
            if(max(stormData.evt.fin.ordered$TOTALDMG) >= 1000)
            {
                stormData.evt.fin.ordered <- stormData.evt.fin.ordered/1000    
                y.lab <- "Total Cost (USD Billions)"    
            }
            else if(max(stormData.evt.fin.ordered$TOTALDMG) < 1)
            {
                stormData.evt.fin.ordered <- (stormData.evt.fin.ordered * 1000)   
                y.lab <- "Total Cost (USD Thousands)"        
            }
            else
            {
                y.lab <- "Total Cost (USD Millions)"        
            }
                
            # remove events that have zero (property + crop) damage
            stormData.evt.fin.ordered <- stormData.evt.fin.ordered[stormData.evt.fin.ordered$TOTALDMG > 0, ]   
            
            n <- if(nrow(stormData.evt.fin.ordered) >= 10) 10 else nrow(stormData.evt.fin.ordered)
            totals <- stormData.evt.fin.ordered$TOTALDMG[1:n]
            
            if(n > 0)
            {
                main.lab <- paste(state,": Total Economic Cost (in USD) by Event (",
                                  startYear," - ",endYear,")",sep = "") 
                
                par(mar=c(9,5,4,2))
                
                p.x3 <- barplot(as.matrix(t(stormData.evt.fin.ordered[1:n,1:2])),
                                names.arg = rep(" ",n),
                                xlab="",
                                ylab=y.lab,
                                main = "",
                                ylim=c(0,1.1 * max(stormData.evt.fin.ordered[1:n,3])),
                                xlim=c(0,n+1), 
                                width=.5, space = 1,
                                cex.names=0.7,las=2,
                                col=c("deepskyblue","deepskyblue4"),
                                border=NA,
                                font.lab=2,
                                font.axis=1)
                
                title(main = main.lab,col.main ="gray20")
                
                axis(side = 1,
                     labels = row.names(stormData.evt.fin.ordered)[1:n],
                     at = p.x3,
                     lty = 0,
                     cex.axis = 0.8,las=2,
                     font = 2)
                
                text(x = p.x3, y =  totals,
                     label = round(totals,digits = 0),
                     pos = 3, cex = 0.8, col = "red")
                
                
                legend("topright", 
                       fill=c("deepskyblue","deepskyblue4"), 
                       legend=c("Property Damage","Crop Damage"),
                       cex=0.8,
                       lty=c(1,1),
                       lwd=c(1,1))
                
                p <- recordPlot()
            }
            else
            {
                p <- plot.new()
            }
        }
    }
}

server <- function(input,output)
{
    output$tabPlot <- renderPlot({noaaPlot(input)})
    
    output$tabSummary <-  renderUI({
        
        text.summary <- " "
        p <- noaaPlot(input)
        
        if(input$selImpact == 1)
        {
            text.summary <- 
            "These events represent top events in the selected time frame and region in terms of their impact to the population. Note that during earlier years monitoring was restricted to only a few events. As a result, choosing the entire duration can result in skewed results and is not to be seen as indicative of the actual impact of the events during that time frame."
            
            if(is.null(p))
            {
                text.summary <- "No events to plot for the selected controls."
            }
        }
        else
        {
            text.summary <- 
            "These events represent top events in the selected time frame and region in terms of their impact to the economy. Economic damage is quantified as the sum of property and crop damage in USD. Note that during earlier years monitoring was restricted to only a few events. As a result, choosing the entire duration can result in skewed results and is not to be seen as indicative of the actual impact of the events during that time frame."
            
            if(is.null(p))
            {
                text.summary <- "No events to summarize for the selected controls."
            }
        }
        
        HTML(paste("<br><br>",text.summary,sep=""))
    })
} 

shinyServer(server)