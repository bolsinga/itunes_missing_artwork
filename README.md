# itunes_missing_artwork
This uses the [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) to learn what media do not have artwork. It then uses the [MusicKit](https://developer.apple.com/documentation/MusicKit/) to search for the artwork on Apple's Catalog.

In Catalina, the Music.app has lost 100s of the artwork it used to have for years. The application itself cannot find this artwork. However using the API provided by Apple, much of the artwork can be found. 

To use this module, you can use [Missing Artwork](https://github.com/bolsinga/MissingArt). It had to be a separate project from this Swift Package. The Xcode project allows the proper signing of an application. In addition, you'll have to use your own developer account and set it up to be able to use MusicKit, just like a regular MusicKit client on iOS or macos.
