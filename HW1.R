
# find common elements in two music set
rm(list=ls())
library(spotifyr)
library(ggjoy)     # useful for plot
library(ggplot2)   # useful for plot
library(tidyverse) # makes possible the use of %>%
library(knitr)     # library to appear data results in a better way
library(lubridate) # useful for date functions


Sys.setenv(SPOTIFY_CLIENT_ID = '25db64d3498a4bc6a5f685acc41e4645')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '2e272fb78502491fb209288ca6d324f3')

access_token <- get_spotify_access_token()

artist <- '21 savage'

artist.audio.features <- get_artist_audio_features(artist)


# album <- artist.audio.features %>%
  # select (track_name, valence) %>%
  # filter(artist.audio.features$album_name == 'i am > i was')


# pull up top 100 valence track
set1 <- c(artist.audio.features%>% 
  arrange(-valence) %>% 
  select(track_name) %>% 
  head(100) )
  
# pull up top 100 danceability tracks
set2 <- c(artist.audio.features%>% 
  arrange(-danceability) %>% 
  select(track_name) %>% 
  head(100)) 

# set1[[1]]
# set2[[1]]

find_match <- function(joyfull, danceability) {
  match_list <- c(match(joyfull[[1]],danceability[[1]]))
  return (match_list)
}

x <- find_match(set1,set2) # example
x # print 
