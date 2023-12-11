options(shiny.usecairo=T)

library(Cairo)
library(svglite)
library(ggplot2)
library(shiny)
library(RColorBrewer)
library(dplyr)
source("generator.R")

shinyServer(function(input, output, session) {
  
  datasetInstance <- reactive({
    generateSequences(input$datasetSize, input$maxSeqLen, input$maxSetSize, input$maxItemId, input$avgSeqLen, input$sdSeqLen, input$avgSetSize, input$sdSetSize, input$avgItemId, input$sdItemId, FALSE, input$decay, input$muItemIdShift)
  })
  
  output$itemPlot <- renderPlot({
    ggplot(data.frame(ProdId=unlist(sequences)), aes(x=ProdId)) +
      geom_density(fill='lightgray') +
      theme_bw() +
      xlab("item id") +
      ylab("density") +
      theme(legend.position = "none")
  })
  
  output$decayPlot <- renderPlot({
    plotRecency(datasetInstance())
  })
  
  output$previewTable <- renderPrint({
    head(datasetInstance(), 50)
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste0("sequences_of_set_", format(Sys.time(), "%d-%m-%YT%H-%M-%S"), ".csv")
    },
    content = function(file)
    {
      write.csv(datasetInstance(), file, row.names = FALSE)
    }
  )
})
