## -------------Twitter Sentiment Analysis-----------
# Authors        : Apurva Shekar, Karishma Visrodia, Ritu Ranjani Ravi Shankar, Sanjana Ramankandath, Vidhi Gandhi.
# Batch          : Fall 2019, MSIS 2506
# References     : Github.com, Stackoverflow, https://github.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107
# Data           : Twitter developer API keys and tokens 
# New Techniques : Scraping, Sentiment Analysis, New packages.
#--------
 

#-- Loading required libraries----- 

library(shiny)
library(twitteR)
library(openssl)
library(httpuv)
library(tm)
library(stringr)
library(dplyr)
library(httr)
library(ROAuth)
library(shiny)


shinyUI(pageWithSidebar(
  headerPanel("Twitter Sentiment Analysis"),
  
  # Getting User Inputs
  
  sidebarPanel(
    tags$head(
      tags$style("body {background-color: black; }"),
      tags$style("label{font-family: BentonSans Book;}"),
      tags$style('h1 {color:#00acee;}'),
      tags$style('body {color:#00acee;}')),
    textInput("searchTerm", "Enter hashtag to search", "#"),
    sliderInput("maxTweets","Number of recent tweets to use for analysis:",min=10,max=800,value=500, step = 30), 
    submitButton(text="Explore")
    
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Top Trending Topics Today",HTML("<div> <h1> Top Trending Topics according to location</h1> </div>"),
               
               selectInput("trendingTable","Choose location to extract trending topics",c("Worldwide","Austria","Bahrain",
                                                                                          "Colombia",
                                                                                          "Denmark","Dominican Republic",
                                                                                          "Egypt","France","Germany","Greece",
                                                                                          "Guatemala","India",
                                                                                          "Indonesia","Israel","Japan",
                                                                                          "Kuwait","Latvia","Lebanon",
                                                                                          "Malaysia","Mexico",
                                                                                          "Norway","Panama",
                                                                                          "Saudi Arabia","Spain",
                                                                                          "Thailand","Turkey",
                                                                                          "Ukraine","United Arab Emirates","Vietnam"), 
               selected = "Worldwide", selectize = FALSE),
               submitButton(text="Search"),
               HTML("<div><h3> Trending on Twitter</h3></div>"),
               tableOutput("trendtable"),
               HTML
               ("<div> </div>")),
      
      
      tabPanel("Word Cloud",HTML("<div><h3>Most used words corresponding to the Trending Hashtag</h3></div>"),plotOutput("word")
               ),
      
      tabPanel("Sentiment Table",HTML( "<div><h3> Sentiment Analysis In Tabular Format </h3></div>"), tableOutput("tabledata")),
         
      tabPanel("Sentiment Analysis", plotOutput("histPos"), plotOutput("histNeg"), plotOutput("histScore")
               ),
      
      tabPanel("Top Users",HTML( "<div><h3> Top 10 users who used that Hashtag </h3></div>"), plotOutput("tweetersplot"),
               tableOutput("tweeterstable"))
               )#end of tabset panel
               )#end of main panel
  
      ))#end of ShinyUI