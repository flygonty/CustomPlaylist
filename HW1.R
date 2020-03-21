
rm(list=ls())

Sys.setenv(SPOTIFY_CLIENT_ID = '25db64d3498a4bc6a5f685acc41e4645')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '2e272fb78502491fb209288ca6d324f3')

access_token <- get_spotify_access_token()

get_artist_audio_features('travis scott')
