Webcom Chat Demo
==============

## Presentation

* Create an account
* Login/logout
* Chat in a general room
* Get a private room with another user

## Setup

* Create an account on [Flexible Datasync](http://io.datasync.orange.com)
* Once you have your account and logged on Webcom, create a new namespace.
* Clone this repository.
* Open the workspace `Webcom-Demo.xcodeproj` 
* Edit [`WebcomManager.swift`](webcom-sdk-ios-demo/WebcomManager.swift) and change `baseURLPath` to point your Webcom namespace.
* Launch the app !

## Release
In order to publish an application using Flexible DataSync SDK to AppStore you need to add a script to your project.

* Go to "Build Phases" pane in your project Target
* Add a "Run script phase"
* Copy paste this script

## License
[MIT](https://opensource.org/licenses/MIT)
