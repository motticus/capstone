library(shiny)
library(tm) 
library(SnowballC) 
library(RWeka) 

bigram <- readRDS("bigram.Rda")
trigram <- readRDS("trigram.Rda")
quadrigram <- readRDS("quadrigram.Rda")

returnVal <- ""

returnPredVal <- function(headval, numericval) {
  strsplititem <- unlist(strsplit(headval," "))
  returnval <- strsplititem[numericval]
}

predictNextWord <- function(inputText) {
  
  #Remove's extraneous characters
  checkText <- Corpus(VectorSource(inputText))
  inspect(checkText)
  checkText <- tm_map(checkText, content_transformer(tolower))
  checkText <- tm_map(checkText, content_transformer(removeNumbers))
  checkText <- tm_map(checkText, content_transformer(removePunctuation))
  removespecial <- function(x) gsub("[^( )[:alnum:]]","",x)
  checkText <- tm_map(checkText, content_transformer(removespecial))
  checkText <- tm_map(checkText, stripWhitespace)
  checkText <- checkText[[1]]$content[1]
  
  #verify number of words at end of entered sentence.  
  words <- unlist(strsplit(checkText," ")) 
  wordcount <- length(words)
  inputWord <- ""
  returnVal <- "N/A"
  if (wordcount>=3){ 
    inputWord <- words[(wordcount-2):wordcount]
  } else if(wordcount == 2){ 
    inputWord <- c("", words)
  } else if(wordcount == 1){
    inputWord <- c("", "", words)
  } else {
    stop("You need to enter a word.") 
  }
    catchword <- paste(inputWord[1], inputWord[2], inputWord[3])
    catchword <- paste("^", catchword, sep="")
    fourpred <- quadrigram[grep(catchword, quadrigram$Word), ]
    #Finds predictive next word on frequency found Starting with Ngram4
    if(nrow(fourpred) > 0) {
      headval <- as.character(head(fourpred$Word,1))
      returnVal <<- returnPredVal(headval, 4)
    } else {
      #no frequency found, try Ngram3
      catchword <- paste(inputWord[2], inputWord[3])
      catchword <- paste("^", catchword, sep="")
      threepred <- trigram[grep(catchword, trigram$Word), ]
      if(nrow(threepred) > 0) {
        headval <- as.character(head(threepred$Word,1))
        returnVal <<- returnPredVal(headval, 3)
      } else {
        #no frequency found, try Ngram2
        catchword <- paste(inputWord[3])
        catchword <- paste("^", catchword, sep="")
        twopred <- bigram[grep(catchword, bigram$Word), ]
        if (nrow(twopred) > 0) {
          headval <- as.character(head(twopred$Word,1))
          returnVal <<- returnPredVal(headval, 2)
        } else {
          #no frequency found, return N/A
          returnVal <<- "N/A"
        }
      }
    }
}

#Shiny Server
shinyServer(function(input, output) {
    output$inputsentence <- renderText({
      input$inputText});
  
    output$prediction <- renderPrint({
      result <- predictNextWord(input$inputText)
      output$thenextword <- renderText({returnVal})
      result
    });
  }
)