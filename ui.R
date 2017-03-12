#Shiny App
#David Mott
#March 2017
library(shiny)
library(markdown)
shinyUI(
  fluidPage(
    titlePanel("Word Prediction for Coursera Capstone Project"),
    sidebarLayout(
      sidebarPanel(
        textInput("inputText", "Please enter a word, phrase, sentence fragment, etc.",value = ""),
        br(), 
        submitButton("Submit"),
        hr(),
        helpText("Press submit after you have chosen a sentence or fragment", 
                 hr(),
                 "The next word is shown.  You can then choose another fragment and enter the next item.",
                 hr(),
                 "This can run a bit slow.  Please be patient.",
                 hr(),
                 "The Diagnostic box is to allow you to see the output from R.")
      ),
      mainPanel(
        strong("Item entered:"),
        strong(code(textOutput('inputsentence'))),
        br(),
        strong("Next predictive word:"),
        strong(code(textOutput('thenextword'))),
        hr(),
        h2("Diagnostics Box"),
        verbatimTextOutput("prediction")
      )
    )
  )
)
