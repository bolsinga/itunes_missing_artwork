# iTunes Missing Artwork
<img src="https://raw.github.com/bolsinga/MissingArt/main/MissingArt/Assets.xcassets/AppIcon.appiconset/Icon.png" width="100">

This is a SwiftUI macOS framework. It uses the [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) to learn what music media in Music.app do not have artwork. It then uses the [MusicKit](https://developer.apple.com/documentation/MusicKit/) to search for the artwork on Apple's Catalog.

It will display everything that is missing, but leave it to the hosting application what to do about it. This is because the best way I found to fix the artwork in Music.app was to run AppleScripts that would repair it. I was reluctant to have an AppleScript dependency in this SwiftUI framework. I also wanted to write a modern library that was published using the Swift Package Manager. 

The inspiration for this was that in macos Catalina, the Music.app has lost 100s of the artwork it used to have for years. The application itself cannot find this artwork. However using the API provided by Apple, much of the artwork can be found. 

To use this module, you can use the [Missing Artwork](https://github.com/bolsinga/MissingArt) application and its Xcode project. It had to be a separate project from this Swift Package. The Xcode project allows the proper signing of an application. In addition, you'll have to use your own developer account and set it up to be able to use MusicKit, just like a regular MusicKit client on iOS or macos.
