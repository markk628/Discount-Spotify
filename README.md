# Taskee App
An iOS app that authenticates users through Spotify, makes network calls to show the user’s top artists, their top 10 tracks and a 30 second preview, and an option to save tracks at the local level
## Demo
### Authentication
![](static/authenticate.gif)
### Saving a Track
![](static/addsongs.gif)
## How It Works
* Users authenticate with their Spotify account so the network calls can be made to pull the proper data
* The HomeController will have a tableview populated by the user's top artists according to Spotify
* Users can browse the artists' top 10 tracks and play a 30 second preview
* Users can save tracks at the local level using CoreData
## Tools
* Spotify API
* Core Data
* Spartan (https://github.com/Daltron/Spartan)
* Kingfisher (https://github.com/onevcat/Kingfisher)
* Snapkit (https://github.com/SnapKit/SnapKit)
