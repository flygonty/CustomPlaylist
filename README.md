# ShowMyPathOfLifeExperience

`Before we start, you should create a client id in WebAPI
Once you finish this step, you'll get Client ID and Client Secret
This ID and Secret should be private. Don't leak it to anyone!
`

## Packages
* spotifyr
`install.packages(spotifyr)`
* lubridate
`install.packages(lubridate)`
* ggjoy
`install.packages(ggjoy)`

## Dataset
### Use personal spotify data
`Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxxxxxxxxxxxxxxx')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxx')
access_token <- get_spotify_access_token()
You should fill up your token`

## Project Architecture
* 1. run R script for capturing user dataset
* 2. show a list of user's top 10 songs
* 3. Then create user's customized playlist
