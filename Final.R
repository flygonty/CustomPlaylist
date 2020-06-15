rm(list=ls())

if(require("Rspotify")) {
  install.packages("Rspotify")
}

library(Rspotify)

appId = 'R_Class'
clientId = '25db64d3498a4bc6a5f685acc41e4645'
clientSecret = '2e272fb78502491fb209288ca6d324f3'

my_oauth <- spotifyOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
save(my_oauth,file="my_oauth")
load("my_oauth")
myProfile <- getUser(user_id="11164078102",token=my_oauth)

getUser<-function(user_id,token){
  req <- httr::GET(paste0("https://api.spotify.com/v1/users/",user_id), httr::config(token = token))
  json1<-httr::content(req)
  dados=data.frame(display_name=json1$display_name,
                   id=json1$id,
                   followers=json1$followers$total,stringsAsFactors = F)
  return(dados)
}

getUserPlaylists <- function( user_id, token ) {
  base_url <- 'https://api.spotify.com/v1/users'
  url <- str_glue('{base_url}/{user_id}/playlists')
  req <- httr::GET(url,httr::config(token=token))
  json1 <- httr::content(req)
  return(json1)
}

createPlaylist <- function( user_id, name, public = TRUE, collaborative = FALSE, description = NULL, token ) {
  base_url <- 'https://api.spotify.com/v1/users'
  url <- str_glue('{base_url}/{user_id}/playlists')
  req <- httr::POST(url,httr::config(token=token))
}

create_playlist <- function(user_id, name, public = TRUE, collaborative = FALSE, description = NULL, authorization = get_spotify_authorization_code()) {
  base_url <- 'https://api.spotify.com/v1/users'
  url <- str_glue('{base_url}/{user_id}/playlists')
  params <- list(
    name = name,
    public = public,
    collaborative  = collaborative,
    description = description
  )
  res <- RETRY('POST', url, body = params, config(token = authorization), encode = 'json')
  stop_for_status(res)
  res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
  return(res)
}
