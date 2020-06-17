rm(list=ls())

library('httr')
library('stringr')

appId = 'R_Class'
clientId = ''
clientSecret = ''


# authentication and get user profile
specificOAuth<-function(app_id,client_id,client_secret,scope='playlist-read-private'){
  spotifyR <- httr::oauth_endpoint(
    authorize = "https://accounts.spotify.com/authorize",
    access = "https://accounts.spotify.com/api/token")
  myapp <- httr::oauth_app(app_id, client_id, client_secret)
  return(httr::oauth2.0_token(spotifyR, myapp,scope = scope))
}

getUserID <- function() {
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret,scope=c('user-read-private','user-read-email'))
  save(my_oauth,file="my_oauth")
  load("my_oauth")
  url <- 'https://api.spotify.com/v1/me'
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  return(json1$id)
}


my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
save(my_oauth,file="my_oauth")
load("my_oauth")
userID = getUserID()


getUserTop <- function(type='artists',limit=10,offset=5,time_range='medium_term') {
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret,scope='user-top-read')
  base_url <- 'https://api.spotify.com/v1/me/top'
  url <- str_glue('{base_url}/{type}')
  params <- list(limit = limit,offset = offset,time_range = time_range )
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  top <- lapply(1:length(json1$items),function(x) json1$items[[x]]$name)
  return(json1)
}

createPlayList <- function(userID,name='New Playlist',description='New playlist description',public='false') {
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret,scope=c('playlist-modify-public','playlist-modify-private'))
  base_url <- 'https://api.spotify.com/v1/users'
  url <- str_glue('{base_url}/{userID}/playlists')
  body <- list(name=name,description=description,public=public)
  req <- RETRY('POST',url,body=body,config(token=my_oauth),encode='json')
}

getTopArtistsID <- function(type='artists',limit=10,offset=5,time_range='medium_term'){
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret,scope='user-top-read')
  base_url <- 'https://api.spotify.com/v1/me/top'
  url <- str_glue('{base_url}/{type}')
  params <- list(limit = limit,offset = offset,time_range = time_range )
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  id <- lapply(1:length(json1$items),function(x) json1$items[[x]]$id)
  return(id)
}

getAnArtist <- function(artistID) {
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
  base_url <- 'https://api.spotify.com/v1/artists'
  url <- str_glue('{base_url}/{artistID}')
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  info <- data.frame(type=json1$genres,name=json1$name,popularity=json1$popularity)
  return(info)
}

getAnArtistTopTracksID<-function(artistID){
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
  base_url <- 'https://api.spotify.com/v1/artists'
  url <- str_glue('{base_url}/{artistID}/top-tracks')
  params <- list(country='US')
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
  json1 <- httr::content(req)
  info <- lapply(1:length(json1$items),function(x) json1$items[[x]]$id)
  return(info)
}

getAnArtistRelatedID<-function(artistID){
  my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
  base_url <- 'https://api.spotify.com/v1/artists'
  url <- str_glue('{base_url}/{artistID}/related-artists')
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
  info <- lapply(1:length(json1$artists),function(x) json1$artists[[x]]$id)
  return(info)
}

getRelatedTrackID<-function(type='artists',limit=10,offset=5,time_range='medium_term'){
  # first get top artists id
  topID <- getTopArtistsID(type,limit,offset,time_range)
  relatedID <- lapply(1:length(topID),function(x) getAnArtistRelatedID(topID[[x]]))
  return(relatedID)
}
