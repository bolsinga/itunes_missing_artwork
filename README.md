# itunes_mising_artwork
This uses the [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) to learn what media do not have artwork. It then uses the [Apple Music API](https://developer.apple.com/documentation/applemusicapi/search) to search for the artwork.

In Catalina, the Music.app has lost 100s of the artwork it used to have for years. The application itself cannot find this artwork. However using the API provided by Apple, the artwork can be found. 

This requires an Apple Developer ID and Music API Key. Pass them in as parameters to the command line program. It will emit the URLs for the missing artwork it is able to find at Apple.
