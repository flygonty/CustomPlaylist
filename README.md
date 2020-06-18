# ShowMyPathOfLifeExperience

## Something you should know...
`Before we start, you should create a client id in WebAPI.
Once you finish this step, you'll get Client ID and Client Secret.
This ID and Secret should be private. Don't leak it to anyone!
Later on, we would use this id and secret to access your account.`

## Packages
* httr
`install.packages(httr)`
* stringr
`install.packages(stringr)`


## Dataset
`Use personal spotify data`
```
Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxxxxxxxxxxxxxxx')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxx')
access_token <- get_spotify_access_token()
```

## Project Architecture
* Run R script for capturing user dataset
* Show a list of user's top 10 songs
* Then create user's customized playlist

## Future
* I would release package 'spotifyR' on CRAN which is a complete package on spotify
* Please wait for a month ! due to my final project and exam.
