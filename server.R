library(shiny)
library(reshape)

# Install the necessary packages.
package_list = c("stringr","ROAuth","RCurl", "ggplot2", "reshape", "tm", "wordcloud","gridExtra", "syuzhet", "plotrix", "twitteR","plyr","e1071")
options(repos='https://cran.rstudio.com/')

for (pkg in package_list)
{
  if (!require(pkg)) {
    next
  }
  install.packages(pkgs=as.character(pkg))
}

shinyServer(function(input, output, session) {
  # For accessing the API, enter the key and token.
  api_key <- "KYX4LqGYUeV32FZVLIF7YnB4c"
  api_secret <- "hbJWEDgitG5kb5Nl63iUaxraqaxmDQqjtfRAG1S0UZTnnZ3pSk"
  access_token <- "963166983255572480-ielV8GxJc1R6aYVc5SE1Ou8GyhDohIK" 
  access_token_secret <- "bqmBYnBl2YMvbiKFHcrU00P04HgC3JsL3bLBNiObILEjP"
  
  # After setting up credentials, setup access using OAUTH protocol
  setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)
  
  # we assume that the positive and negative words. These words are available on the web to identify if a sentence is positive/negative.
  positive = scan('positive_words.txt', what='character', comment.char=';')
  negative = scan('negative_words.txt', what='character', comment.char=';')
  
  # Display sentiment analysis in tabular format
  analyze_sentiments<-function(result)
  {
    # Let us create a copy first.
    test_positive=result[[2]]
    test_negative=result[[3]]
    
    # Create some temporary dfs for positive and negatives.
    test_positive$text=NULL
    test_negative$text=NULL
    
    # Create a copy and some temporary DFs for score.
    test_score=result[[1]]
    test_score$text=NULL
    
    # Storing the first row(Containing the sentiment scores)
    overall_row=test_score[1,]
    positive_row=test_positive[1,]
    negative_row=test_negative[1,]
    overall_melt=melt(overall_row, var='Score')
    positive_melt=melt(positive_row, var='Positive')
    negative_melt=melt(negative_row, var='Negative') 
    overall_melt['Score'] = NULL
    positive_melt['Positive'] = NULL
    negative_melt['Negative'] = NULL

    # Using this data, create a dataframe for positive, negative data frames.
    overall_df = data.frame(Text=result[[1]]$text, Score=overall_melt)
    positive_df = data.frame(Text=result[[2]]$text, Score=positive_melt)
    negative_df = data.frame(Text=result[[3]]$text, Score=negative_melt)
    
    # Merging three data frames into one
    final_df=data.frame(Text=overall_df$Text, Positive=positive_df$value, Negative=negative_df$value, Score=overall_df$value)
    
    return(final_df)
  }
  
  compute_percentage<-function(final_df)
  {
    # Use temporaries for local function use.
    pos_score=final_df$Positive
    neg_score=final_df$Negative
    
    final_df$PosPercent = pos_score/ (pos_score+neg_score)
    
    # Let us replace NAs with zero. This is because certain hashtags might not have tweets and we would need to 
    # replace them.
    positive_score = final_df$PosPercent
    positive_score[is.nan(positive_score)] <- 0
    final_df$PosPercent = positive_score*100
    
    # Calculating negative percentage.
    final_df$NegPercent = neg_score/ (pos_score+neg_score)
    
    # ditto as above. Let us replace NAs with zero. This is because certain hashtags might not have tweets and we would need to 
    # replace them.
    negative_score = final_df$NegPercent
    negative_score[is.nan(negative_score)] <- 0
    final_df$NegPercent = negative_score*100
    return(final_df)
  }
  
  positive_words<<-c(positive)
  negative_words<<-c(negative)
  
  tweet_list<-reactive({tweet_list<-searchTwitter(input$searchTerm, n=input$maxTweets, lang="en") })
  
  search_tweets_and_return<-function(tweet_list)
  {
    # Let us transform this to a df.
    twitter_data<- do.call("rbind",lapply(tweet_list,as.data.frame))
  
    # While it is fun to show them, emoticons will be removed from the tweets for better view as well
    twitter_data$text <- sapply(twitter_data$text,function(row) iconv(row, "latin1", "ASCII", sub=""))
    
    # Some regex magic to remove the URLs: https://stackoverflow.com/questions/11331982/how-to-remove-any-url-within-a-string-in-python
    twitter_data$text = gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", twitter_data$text)
    return (twitter_data$text)
  }
  tweets<-reactive({tweets<-search_tweets_and_return(tweet_list() )})
  
  # Calculating sentiment score
  compute_sentiment_score <- function(sentences, positive, negative, .progress='none')
  {
    list=lapply(sentences, function(sentence, positive, negative)
    {
      clean_sentence = gsub('[[:punct:]]',' ',sentence) 
      clean_sentence = gsub('[[:cntrl:]]','',sentence)
      clean_sentence = gsub('\\d+','',sentence) # Removes decimal numbers
      clean_sentence = gsub('\n','',sentence) # Removes new lines
      
      clean_sentence = tolower(clean_sentence)
      word_list = str_split(clean_sentence, '\\s+')
      words = unlist(word_list)
      pos_matches = match(words, positive)
      neg_matches = match(words, negative) 
      pos_matches = !is.na(pos_matches) # Add only positive words and no NA
      neg_matches = !is.na(neg_matches)
      positive_score=sum(pos_matches)
      negative_score = sum(neg_matches)
      score = sum(pos_matches) - sum(neg_matches)
      list1=c(score, positive_score, negative_score) # Append the scores to the list
      return (list1)
    }, positive, negative)
    score_new=lapply(list, `[[`, 1)
    positive_score_list=score=lapply(list, `[[`, 2)
    negative_score_list=score=lapply(list, `[[`, 3)
    
    scores_df = data.frame(score=score_new, text=sentences)
    positive_df = data.frame(Positive=positive_score_list, text=sentences)
    negative_df = data.frame(Negative=negative_score_list, text=sentences)
    
    list_df=list(scores_df, positive_df, negative_df)
    return(list_df)
  }
  result<-reactive({result<-compute_sentiment_score(tweets(), positive, negative, .progress='none')})
  
  final_df<-reactive({final_df<-analyze_sentiments(result())})
  table_final_percentage<-reactive({table_final_percentage<-compute_percentage(  final_df() )})
  
  output$tabledata<-renderTable(table_final_percentage())	
  
  # Utility to clean the word cloud data.
  clean_wordcloud_data<-function(text)
  {
    corpus_data <- VCorpus(VectorSource(text))
    
    # Cleanse data for word cloud by transforming the case, removing stop words, whitespaces etc., and return the data. 
    word_cloud_data <- tm_map(corpus_data, removePunctuation)
    word_cloud_data <- tm_map(word_cloud_data, content_transformer(tolower))
    word_cloud_data <- tm_map(word_cloud_data, removeWords, stopwords("english"))
    word_cloud_data <- tm_map(word_cloud_data, removeNumbers)
    word_cloud_data <- tm_map(word_cloud_data, stripWhitespace)
    return (word_cloud_data)
  }
  
  library(tm)
  library(wordcloud)
  text_word<-reactive({text_word<-clean_wordcloud_data(tweets())})

  output$word <- renderPlot({ wordcloud(text_word(),random.order=F,max.words=80, col=rainbow(100), main="WordCloud", scale=c(4.5, 1)) })
  
  # Let us render a plot for postive and negative words along with the overall score.
  output$histPos<- renderPlot({ hist(final_df()$Positive, col=rainbow(10), main="Positive Sentiment", xlab = "Positive Score") })
  output$histNeg<- renderPlot({ hist(final_df()$Negative, col=rainbow(10), main="Negative Sentiment", xlab = "Negative Score") })
  output$histScore<- renderPlot({ hist(final_df()$Score, col=rainbow(10), main="Overall Score", xlab = "Overall Score") })	
  
  # Get the top trends - Reference - https://bigdataenthusiast.wordpress.com/category/r/
  get_top_trends <- function(place)
  {
    all_trends = availableTrendLocations() # will return the list of all countries and woeid
    woeid = all_trends[which(all_trends$name==place),3]
    trend = getTrends(woeid)
    final_trends = trend[1:2]
    
    trends_bind <- cbind(final_trends$name)
    trends_list <- unlist(strsplit(trends_bind, split=", "))
    clean_trends <- grep("trends_bind", iconv(trends_bind, "latin1", "ASCII", sub="trends_bind")) # Removing the emoticons
    final_trends_data <- trends_bind[-clean_trends]
    return (final_trends_data)
  }
  
  trend_table<-reactive({ trend_table<-get_top_trends(input$trendingTable) })
  output$trendtable <- renderTable(trend_table())
  
  # TOP 20 USER CHARTS
  
  # Top charts of a particular hashtag - Barplot
  toptweeters<-function(tweetlist)
  {
    tweets <- twListToDF(tweetlist)
    tweets <- unique(tweets)
    # Make a table for the number of tweets per user
    tweet_data <- as.data.frame(table(tweets$screenName)) 
    tweet_data <- tweet_data[order(tweet_data$Freq, decreasing=TRUE), ] #descending order of top charts according to frequency of tweets
    names(tweet_data) <- c("User","Tweets")
    return (tweet_data)
  }
  
  # Plot the table for the top 10 charts
  tweet_data<-reactive({tweet_data<-toptweeters(tweet_list())})
  output$tweetersplot<-renderPlot (barplot(head(tweet_data()$Tweets, 10), names=head(tweet_data()$User, 10), horiz=F, las=1, main="Top 10 users associated with the Hashtag", col="coral") )
  output$tweeterstable<-renderTable(head(tweet_data(),10))
})