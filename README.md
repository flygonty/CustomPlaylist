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
* How to access your token ?
```
appId = ''
clientId = ''
clientSecret = ''

my_oauth <- allScopeOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
save(my_oauth,file="my_oauth")
load("my_oauth")

# By doing this you could successfully access !
# If you don't want to use all scope you could use this function
# my_oauth <- specificOAuth(app_id=appId,client_id=clientId,client_secret=clientSecret)
```

## Project Architecture
* Run R script for capturing user dataset
* Show a list of user's top 10 songs
* Then create user's customized playlist

## Project Outcome
* Build Custom Playlist
* Can build danceable and energy playlist

## Future
* I would release package 'spotifyR' on CRAN which is a complete package on spotify
* Please wait for a month ! due to my final project and exam.
