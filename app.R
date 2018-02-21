#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(reshape)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage( 
  titlePanel("Explore 1958 birth cohort data"),
  h4("Protein Affecting Variants: Loss of function, inframe indels, and predicted deleterious and damaging missense variants (by SIFT and PolyPhen respectively)"),
  h4("Loss of function Variants: stop gained, stop lost, start lost, frameshift variant, splice donor and splice acceptor variants"),
  
  # Create a new Row in the UI for selectInputs
  sidebarLayout(
    sidebarPanel(
      selectInput("lof",
                  "Variant impact:",
                  c("Protein Affecting",
                    "Loss of Function")),
      selectInput("af",
                  "Variant Allele Frequency:",
                  c("All",
                    "<0.05",
                    "<0.01")),
      textInput("gene",
                "Gene:",
                ""),
      downloadButton("downloadData", "Download")),
    mainPanel(
      fluidRow(
        column(5, align="center", textOutput("text"), tableOutput("tablesum")),
        column(5, align="center", plotOutput("summary"))))),
  fluidRow(
    DT::dataTableOutput("table")))
# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Filter data based on selections
  datasetInput <- reactive({load("wes_1958BC_csqfiltered_short_20180214.Rdata")
    data <- vv.short
    if (input$lof != "Protein Affecting") {
      data <- data[data$IMPACT == "HIGH",]
    }
    if (input$af == "<0.05") {
      data <- data[data$AF < 0.05,]
    }
    if (input$af == "<0.01") {
      data <- data[data$AF < 0.01,]
    }
    if (input$gene != "") {
      data <- data[grepl(toupper(input$gene), data$SYMBOL),]
    }
    data})
  
  output$summary <- renderPlot({load("wes_1958BC_csqfiltered_short_20180214.Rdata")
    data <- vv.short
    if (input$gene != "") {
      data <- data[grepl(toupper(input$gene), data$SYMBOL),]
      out <- data.frame(impact=c("LoF", "Missense"), 
                        common=c(sum(data[data$IMPACT == "HIGH" & data$AF >= 0.01,]$AC, na.rm=TRUE), sum(data[grepl("missense", data$Consequence)& data$AF >= 0.01,]$AC, na.rm=TRUE)),
                        rare5=c(sum(data[data$IMPACT == "HIGH" & data$AF < 0.01,]$AC, na.rm=TRUE), sum(data[grepl("missense", data$Consequence)& data$AF < 0.01,]$AC, na.rm=TRUE)))
      out.melt <- melt(out)
      title <- paste("", toupper(input$gene), sep="")
      ggplot(out.melt, aes(impact, value, fill=variable, label=value)) + geom_bar(stat="identity") + 
        labs(title=title, x="Variant consequence", y="Allele Count") +
        scale_fill_discrete(name="Variant Allele Frequency", labels=c("AF >= 0.01", "AF < 0.01")) +
        geom_text(data=subset(out.melt, value != 0), size = 3, position = position_stack(vjust = 0.5))}
    
  })
  
  output$tablesum <- renderTable({load("wes_1958BC_csqfiltered_short_20180214.Rdata")
    data <- vv.short
    if (input$gene != "") {
      data <- data[grepl(toupper(input$gene), data$SYMBOL),]
      out <- data.frame(All=c(sum(data[data$IMPACT == "HIGH",]$AC, na.rm=TRUE), sum(data[grepl("missense", data$Consequence),]$AC, na.rm=TRUE)),
                        rare5=c(sum(data[data$IMPACT == "HIGH" & data$AF < 0.05,]$AC, na.rm=TRUE), sum(data[grepl("missense", data$Consequence)& data$AF < 0.05,]$AC, na.rm=TRUE)),
                        rare1=c(sum(data[data$IMPACT == "HIGH" & data$AF < 0.01,]$AC, na.rm=TRUE), sum(data[grepl("missense", data$Consequence)& data$AF < 0.01,]$AC, na.rm=TRUE)))
      colnames(out) <- c("All", "AF<0.05", "AF<0.01")
      row.names(out) <- c("LoF", "Missense")
      out
      }
  }, spacing = "l", rownames=TRUE, digits=0, hover=TRUE)
  
  output$table <- DT::renderDataTable({DT::datatable(
    datasetInput(), options = list(lengthMenu = c(10, 100, 200), pageLength = 10)
  )})
  
  output$text <- renderText({
    if (input$gene != "") {
    title <- paste("Occurences of variants in gene: ", toupper(input$gene), sep="")
    title}
    })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("wes_1958_", input$gene, "_", input$lof, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(datasetInput(), file, row.names = FALSE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

