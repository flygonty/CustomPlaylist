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

getAListOfCurrentUserPlaylists<-function(limit=10,offset=5,my_oauth){
  url <- 'https://api.spotify.com/v1/me/playlists'
  req <- httr::GET(url,httr::config(token=my_oauth))
  json1 <- httr::content(req)
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

getAudioFeaturesForSeveralTrack<-function(ids,my_oauth){
  url <- 'https://api.spotify.com/v1/audio-features'
  params <- list(ids=ids)
  req <- httr::GET(url,httr::config(token=my_oauth),query=params)
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

addItemsToaPlaylist<-function(playlist_id,my_oauth,uris){
  base_url <- 'https://api.spotify.com/v1/playlists'
  url <- str_glue('{base_url}/{playlist_id}/tracks')
  params <- list(uris=uris)
  req <- httr::POST(url,httr::config(token=my_oauth),query=params)
}

######################################################
##################Project Start#######################
######################################################

# create a new playlist
createPlayList(userID,my_oauth=my_oauth)

# Get user top artist ID and track ID
topArtistID<-getTopArtistsID(my_oauth = my_oauth)
trackID <- lapply(1:length(topArtistID),function(x) getAnArtistTopTracksID(topArtistID[[x]],my_oauth = my_oauth))

# Get new playlist id
playlist_json <- getAListOfCurrentUserPlaylists(my_oauth = my_oauth)
playlist_id <- playlist_json$items[[1]]$id # first always new playlist

# uris <- lapply(1:length(trackID),function(x) lapply( 1:length(trackID[[x]]), function(y) paste0("spotify:track:",trackID[[x]][[y]])) )
# uris_list <- lapply(1:length(uris), function(x) paste0(uris[[x]], collapse = ',')) # 10 tracks

ids <- lapply(1:length(trackID), function(x) paste0(trackID[[x]], collapse = ',')) # 10 tracks [[1]]
# uris_list <- paste0(uris_list, collapse = ',') 

# Get feature
# features <- getAudioFeaturesForSeveralTrack(ids[[1]],my_oauth)
features_list <- lapply(1:length(ids), function(x) getAudioFeaturesForSeveralTrack(ids[[x]],my_oauth))




danceabilityTracksList <- lapply(1:length(features_list),
                          function(x) lapply(1:length(features_list[[x]]$audio_features), 
                          function(y) if(features_list[[x]]$audio_features[[y]]$danceability>0.75) features_list[[x]]$audio_features[[y]]$id))


for(i in c(1:length(danceabilityTracksList))){ # clean null data
  danceabilityTracksList[[i]][sapply(danceabilityTracksList[[i]], is.null)] <- NULL
}

danceabilityTracksList <- danceabilityTracksList[lapply(danceabilityTracksList,length)>0] # remove 0 elements list
danceabilityTracksList <- lapply(1:length(danceabilityTracksList), function(x) lapply(1:length(danceabilityTracksList[[x]]), function(y) paste0('spotify:track:',danceabilityTracksList[[x]][[y]])))
danceList <- lapply(1:length(danceabilityTracksList), function(x) paste(danceabilityTracksList[[x]],collapse = ',') ) # tracks_ids


#########
# danceabilityTracks <- lapply(1:length(features$audio_features), function(x) getDanceability(features,x) )
# danceabilityTracks[sapply(danceabilityTracks, is.null)] <- NULL # remove NULL elements
# danceabilityTracksIDs <- paste0(danceabilityTracks, collapse = ',')
#########

lapply(1:length(danceList), function(x) addItemsToaPlaylist(playlist_id,my_oauth = my_oauth,danceList[[x]]) )

getDanceabilityPlaylist<-function(userID,my_oauth=my_oauth){
  createPlayList(userID,name='Dance playlist',description='Dance playlist',my_oauth=my_oauth)
  # Get artist id and new playlist id
  topArtistID<-getTopArtistsID(my_oauth = my_oauth)
  trackID <- lapply(1:length(topArtistID),function(x) getAnArtistTopTracksID(topArtistID[[x]],my_oauth = my_oauth))
  # Get new playlist id
  playlist_json <- getAListOfCurrentUserPlaylists(my_oauth = my_oauth)
  playlist_id <- playlist_json$items[[1]]$id # first always new playlist
  ids <- lapply(1:length(trackID), function(x) paste0(trackID[[x]], collapse = ',')) # 10 tracks [[1]]
  features_list <- lapply(1:length(ids), function(x) getAudioFeaturesForSeveralTrack(ids[[x]],my_oauth))
  danceabilityTracksList <- lapply(1:length(features_list),
                            function(x) lapply(1:length(features_list[[x]]$audio_features), 
                              function(y) if(features_list[[x]]$audio_features[[y]]$danceability>0.75) features_list[[x]]$audio_features[[y]]$id))
  for(i in c(1:length(danceabilityTracksList))){ # clean null data
    danceabilityTracksList[[i]][sapply(danceabilityTracksList[[i]], is.null)] <- NULL
  }
  
  danceabilityTracksList <- danceabilityTracksList[lapply(danceabilityTracksList,length)>0] # remove 0 elements list
  danceabilityTracksList <- lapply(1:length(danceabilityTracksList), function(x) lapply(1:length(danceabilityTracksList[[x]]), function(y) paste0('spotify:track:',danceabilityTracksList[[x]][[y]])))
  danceList <- lapply(1:length(danceabilityTracksList), function(x) paste(danceabilityTracksList[[x]],collapse = ',') ) # tracks_ids
  lapply(1:length(danceList), function(x) addItemsToaPlaylist(playlist_id,my_oauth = my_oauth,danceList[[x]]) )
  
}

getDanceabilityPlaylist(userID = userID,my_oauth = my_oauth)

getEnergyPlaylist<-function(userID,my_oauth=my_oauth){
  createPlayList(userID,name='Energy playlist',description='Energy playlist',my_oauth=my_oauth)
  # Get artist id and new playlist id
  topArtistID<-getTopArtistsID(my_oauth = my_oauth)
  trackID <- lapply(1:length(topArtistID),function(x) getAnArtistTopTracksID(topArtistID[[x]],my_oauth = my_oauth))
  # Get new playlist id
  playlist_json <- getAListOfCurrentUserPlaylists(my_oauth = my_oauth)
  playlist_id <- playlist_json$items[[1]]$id # first always new playlist
  ids <- lapply(1:length(trackID), function(x) paste0(trackID[[x]], collapse = ',')) # 10 tracks [[1]]
  features_list <- lapply(1:length(ids), function(x) getAudioFeaturesForSeveralTrack(ids[[x]],my_oauth))
  energyTracksList <- lapply(1:length(features_list),
                                   function(x) lapply(1:length(features_list[[x]]$audio_features), 
                                                      function(y) if(features_list[[x]]$audio_features[[y]]$energy>0.75) features_list[[x]]$audio_features[[y]]$id))
  for(i in c(1:length(energyTracksList))){ # clean null data
    energyTracksList[[i]][sapply(energyTracksList[[i]], is.null)] <- NULL
  }
  
  energyTracksList <- energyTracksList[lapply(energyTracksList,length)>0] # remove 0 elements list
  energyTracksList <- lapply(1:length(energyTracksList), function(x) lapply(1:length(energyTracksList[[x]]), function(y) paste0('spotify:track:',energyTracksList[[x]][[y]])))
  energyList <- lapply(1:length(energyTracksList), function(x) paste(energyTracksList[[x]],collapse = ',') ) # tracks_ids
  lapply(1:length(energyList), function(x) addItemsToaPlaylist(playlist_id,my_oauth = my_oauth,energyList[[x]]) )
  
}


getEnergyPlaylist(userID = userID,my_oauth = my_oauth)
