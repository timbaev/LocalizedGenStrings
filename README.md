# LocalizedGenStrings 🌐

**LocalizedGenStrings** is a command line tool to find localized strings from code and storyboards, and generate *Localizable.strings* file for Xcode project. Also you can translate you strings using [Yandex.Translate](https://translate.yandex.com).

## Use Case

To localize strings use extension:
```swift
func localized(tableName: String? = nil, comment: String = "") -> String {
    return NSLocalizedString(self, tableName: tableName, bundle: Bundle.main, value: "", comment: comment)
}
```
Usage:
```swift
static let unknownErrorTitle = "Something went wrong".localized()

let formattedString = String(format: "%@ now".localized(), status)
```

To localize storyboards UI elements create custom classes for necessary element, for example:
```swift
class LocalizableLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.text = self.text?.localized()
    }
}
```
And set `LocalizableLabel` custom class on Storyboard

## How script work?
**LocalizedGenStrings** looking for localized strings from code whiche used `localized()` extension. Also using *ibtool* script grabbed all strings from UI elements (regardless of whether a custom class is used or not). And finally, if *Localizable.strings* file already exists into project, script will be merge strings (if string already in file, value not will be replaced).

## Features
To find localization strings and generate `Localizable.strings` file simply run in the root folder of you project (where is located `.xcodeproj` file):
```
$ LocalizedGenStrings
```
After that in your Xcode project you can see created `Localizable.strings` file.

To generate `Localizable.strings` file for specific language use:
```
$ LocalizedGenStrings --lang language_code --key yandex_translate_api_key
```
After that in your Xcode project you can see `Localizable.strings` file for you language:
![Localizable.strings files screenshot](https://i.ibb.co/7jFShx4/2019-08-12-19-06-28.png "Localizable.strings files screenshot")

See available `language_code` on [this page](https://tech.yandex.com/translate/doc/dg/concepts/api-overview-docpage/#api-overview__languages)

Get API key on [this page](https://translate.yandex.com/developers/keys)

[Full documentation](https://tech.yandex.com/translate/)

**NOTE**: the quality of the translation depends only on Yandex.Translate. Be sure to check the correctness of the translation and the integrity of the translated strings.

Also you can set custom path to you Xcode project:
```
$ LocalizedGenStrings --path path/to/xcodeproj/folder
```

## Installing
### Homebrew
```
$ brew tap timbaev/LocalizedGenStrings https://github.com/timbaev/LocalizedGenStrings.git
$ brew install LocalizedGenStrings
```
### Manually
```
$ git clone https://github.com/timbaev/LocalizedGenStrings.git
$ cd LocalizedGenStrings
$ make install
```

## Requirements
* Xcode 10.3+ and Swift 5+

## Help, feedback or suggestions?
* [Open an issue](https://github.com/timbaev/LocalizedGenStrings/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
* [Open a PR](https://github.com/timbaev/LocalizedGenStrings/pull/new/master) if you want to make some change to LocalizedGenStrings.
* Contact [me on Twitter](https://twitter.com/timbaev) if you have any questions
