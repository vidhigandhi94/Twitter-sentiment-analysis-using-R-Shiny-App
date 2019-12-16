# Twitter-sentiment-analysis-using-R-Shiny-App
Real time Tweets are imported through Twitter API keys for the last 7 days. After cleaning data, Lexical analysis has been used to calculate the sentiment score of the tweets for the particular input of hashtag. The app displays the opinion through histogram, word cloud and tables. 

# Prerequisites
  
  Twitter API
 
  An IDE for R Programming (RStudio)
  
  Shiny & Plotrix (R Libraries)
  
  Positive & Negative Words List (To compare Tweets for Sentiment)
          This file can be downloaded from : http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html

# Frontend - Shiny App     Features

**Top Trending Topics Today**

The table is shown which displays the top trending hashtags on Twitter of the location that has been selected. A WOEID (Where On Earth IDentifier) is a unique 32-bit reference identifier, which is generated, and R uses the WOEID of the selected place to obtain the trending hashtags from that location.

**Word Cloud**

Wordcloud format is useful for quickly perceiving the most prominent terms and for locating a term alphabetically to determine its relative prominence. We have used tm and wordcloud package to depict the most used words associated with the hashtag in a pictorial representation under the Wordcloud tab.

**Sentiment Analysis Table**

Displays the sentiment analysis of tweets in a tabular format. The table includes the tweets as well as the percentage of positive/negative emotion in the text. This calculated using simple arithmetic to understand the overall sentiment in a better manner.

**Sentiment Analysis Plot**

Histograms of positive, negative and overall score are found under the Histogram tab for graphically analyzing the intensity of emotion in the tweeters.

**Top Users**

The bar plot shows the top tweeters according to the frequency with which they used the input hashtag in the last 7 days. This tab also shows a table of the username of the tweeter and the frequency of the hashtag used.
