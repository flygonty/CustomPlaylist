rm(list=ls())

library('httr')
library('stringr')

appId = ''
clientId = ''
clientSecret = ''

allScope <- c('user-read-playback-position','user-read-email',
'user-library-read','user-top-read','playlist-modify-public',
'user-follow-read','user-read-playback-state','user-modify-playback-state',
'user-read-private','playlist-read-private','user-library-modify',
'playlist-read-collaborative','playlist-modify-private','user-follow-modify',
'user-read-currently-playing','user-read-recently-played')

# limit scope
specificOAuth<-function(app_id,client_id,client_secret,scope='playlist-read-private'){
  spotifyR <- httr::oauth_endpoint(
    authorize = "https://accounts.spotify.com/authorize",
    access = "https://accounts.spotify.com/api/token")
  myapp <- httr::oauth_app(app_id, client_id, client_secret)
  return(httr::oauth2.0_token(spotifyR, myapp,scope = scope))
}

# unlock all scope
allScopeOAuth<-function(app_id,client_id,client_secret){
  scope<-allScope <- c('user-read-playback-position','user-read-email',
                       'user-library-read','user-top-read','playlist-modify-public',
                       'user-follow-read','user-read-playback-state','user-modify-playback-state',
                       'user-read-private','playlist-read-private','user-library-modify',
                       'playlist-read-collaborative','playlist-modify-private','user-follow-modify',
                       'user-read-currently-playing','user-read-recently-played')
  spotifyR <- httr::oauth_endpoint(
    authorize = "https://accounts.spotify.com/authorize",
    access = "https://accounts.spotify.com/api/token")
  myapp <- httr::oauth_app(app_id, client_id, client_secret)
  return(httr::oauth2.0_token(spotifyR, myapp,scope = scope))
}

# authentication and get user profile
my_oauth <- allScopeOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
save(my_oauth,file="my_oauth")
load("my_oauth")


# token == my_oauth
getUserID <- function(my_oauth) {
  url <- 'https://api.spotify.com/v1/me'
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  return(json1$id)
}

# get user ID
userID=getUserID(my_oauth)

getUserTop <- function(type='artists',limit=10,offset=5,time_range='medium_term',my_oauth){
  base_url <- 'https://api.spotify.com/v1/me/top'
  url <- str_glue('{base_url}/{type}')
  params <- list(limit = limit,offset = offset,time_range = time_range )
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  top <- lapply(1:length(json1$items),function(x) json1$items[[x]]$name)
  return(json1)
}

createPlayList <- function(userID,name='New Playlist',description='New playlist description',public='false',my_oauth) {
  base_url <- 'https://api.spotify.com/v1/users'
  url <- str_glue('{base_url}/{userID}/playlists')
  body <- list(name=name,description=description,public=public)
  req <- RETRY('POST',url,body=body,httr::config(token=my_oauth),encode='json')
}


getTopArtistsID <- function(type='artists',limit=10,offset=5,time_range='medium_term',my_oauth){
  base_url <- 'https://api.spotify.com/v1/me/top'
  url <- str_glue('{base_url}/{type}')
  params <- list(limit = limit,offset = offset,time_range = time_range )
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  id <- lapply(1:length(json1$items),function(x) json1$items[[x]]$id)
  return(id)
}

getAnArtist <- function(artistID,my_oauth) {
  base_url <- 'https://api.spotify.com/v1/artists'
  url <- str_glue('{base_url}/{artistID}')
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  info <- data.frame(type=json1$genres,name=json1$name,popularity=json1$popularity)
  return(info)
}

getAnArtistTopTracksID<-function(artistID,my_oauth){
  base_url <- 'https://api.spotify.com/v1/artists'
  url <- str_glue('{base_url}/{artistID}/top-tracks')
  params <- list(country='US')
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  info <- lapply(1:length(json1$tracks),function(x) json1$tracks[[x]]$id)
  return(info)
}

getAnArtistRelatedID<-function(artistID,my_oauth){
  base_url <- 'https://api.spotify.com/v1/artists'
  url <- str_glue('{base_url}/{artistID}/related-artists')
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  info <- lapply(1:length(json1$artists),function(x) json1$artists[[x]]$id)
  return(info)
}

getRelatedTrackID<-function(type='artists',limit=10,offset=5,time_range='medium_term',my_oauth){
  # first get top artists id
  topID <- getTopArtistsID(type,limit,offset,time_range,my_oauth)
  relatedID <- lapply(1:length(topID),function(x) getAnArtistRelatedID(topID[[x]],my_oauth))
  return(relatedID)
}

getAnAnalysisForTrack<-function(trackID,my_oauth){
  base_url <- 'https://api.spotify.com/v1/audio-analysis'
  url <- str_glue('{base_url}/{trackID}')
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  return(json1)
}

getAudioFeaturesForATrack<-function(trackID,my_oauth){
  base_url <- 'https://api.spotify.com/v1/audio-features'
  url <- str_glue('{base_url}/{trackID}')
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  return(json1)
}

getATrack<-function(trackID,my_oauth){
  base_url <- 'https://api.spotify.com/v1/tracks'
  url <- str_glue('{base_url}/{trackID}')
  params <- list(country='US')
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  return(json1)
}

createPlayList(userID,my_oauth=my_oauth)
