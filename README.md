# ImageClassificationDemo

This is a demo project to prove adding basic machine learning to an app using Apple's frameworks is easy and fun.
As it was written as a proof of concept and in several evenings be aware it can have some bugs. Please DM me or create a pull request.

## Getting Started

Just clone repo and open via Xcode.

### Availability

iOS 13.0+
macOS 10.15+
Mac Catalyst 13.0+

### Prerequisites

Project uses [Unsplash API](https://unsplash.com/developers). In order to fetch images you need a client id (called `Access Key` in Unsplash dashboard). Just put this key as enviroment variable as a `CLIENT_ID` parameter (if you're not familiar—here is a [tutorial](https://nshipster.com/launch-arguments-and-environment-variables/)).
Don't forget that variable should be in each scheme you run (like iOS and macOS one).

### Frameworks

Demo app uses SwiftUI and Combine.
It's based on [Composable Architecture](http://www.dropwizard.io/1.0.2/docs/) for faster and more fun development.
To fetch images—[Nuke](https://github.com/kean/Nuke) and it's plugins.

## Authors

* **Jaleel Akbashev** - [akbashev](https://github.com/akbashev)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
