library(shiny)
library(rgl)
library(colourpicker)

datasetTab <- "$('li.active a').first().html()==='Dataset properties' || $('li.active a').first().html()==='Preview'"
helpTab <- "$('li.active a').first().html()==='Help'"


shinyUI(fluidPage(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")),
  tags$head(tags$link(rel = "icon", type = "image/png", href = "img/favicon.png")),
  tags$head(tags$script(src = "js/custom.js")),
  
  # Header
  fluidRow(
    column(width = 12, includeMarkdown("www/header.md"), class="header")#,
    #column(width = 4, a(img(src="img/put_logo.svg", id="logo"), href="http://www.put.poznan.pl/"))
  ),
  br(),
  sidebarLayout(
    # Sidebar with options
    sidebarPanel(
      conditionalPanel(datasetTab,
                       numericInput("datasetSize", label="Dataset size", min=1, max=1000, value=500, step=100),
                       numericInput("maxSeqLen", label = "Maximum sequence length", min = 1, max = 500, value = 100, step=1),
                       sliderInput("avgSeqLen", label="Average sequence length", min=0, max=1, value=0.1, step=0.01),
                       sliderInput("sdSeqLen", label="Sequence length std. dev.", min=0, max=2, value=0.1, step=0.01),
                       numericInput("maxSetSize", label = "Maximum set size", min = 1, max = 100, value = 50, step=1),
                       sliderInput("avgSetSize", label="Average set size", min=0, max=1, value=0.1, step=0.01),
                       sliderInput("sdSetSize", label="Set size std. dev.", min=0, max=2, value=0.1, step=0.01),
                       numericInput("maxItemId", label = "Maximum item id", min = 1, max = 10000, value = 500, step=1),
                       sliderInput("avgItemId", label="Average itemId", min=0, max=1, value=0.1, step=0.01),
                       sliderInput("sdItemId", label="Item id std. dev.", min=0, max=2, value=0.1, step=0.01),
                       sliderInput("muItemIdShift", label="Mean item id shift", min=0, max=1, value=0, step=0.01),
                       sliderInput("decay", label = "Decay", min = 0, max = 1, value = 0, step=0.01, animate=animationOptions(interval = 500, loop = T)),
                       numericInput("seed", label="Random seed", value=23),
                       downloadButton("downloadData", label = "Save to csv", class="dataset-download-btn")),
      conditionalPanel(helpTab,
                       includeMarkdown("www/helpContents.md"),
                       class="measures")
    ),
    
    # Main panel
    mainPanel(
      tabsetPanel(id = "tabs",
        tabPanel("Dataset properties", 
                 div(class = "plot-container",
                     fluidRow(
                       column(width = 6, plotOutput("itemPlot", height = "250px")),
                       column(width = 6, plotOutput("decayPlot", height = "250px"))
                       )#,
                     #fluidRow(
                      # column(width = 6, plotOutput("recencyPlot", height = "250px")),
                       #column(width = 6, plotOutput("correlationPlot", height = "250px"))
                       #)
                     )
                 ),
        tabPanel("Preview",
                 h4("This section presents the first 50 rows of the generated dataset."),
                 tableOutput("previewTable")
        ),
        tabPanel("Help",
                 withMathJax(),
                 div(includeMarkdown("www/help.md"), class="help"))
      )
    )
  ),
  title = "Sequences of Sets Dataset Generator"
))