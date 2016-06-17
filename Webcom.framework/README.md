#### Create an account

1. Create an account on [http://datasync.orange.com](http://datasync.orange.com)
2. Once you're logged, create a namespace

#### Setup your project

You can configure your project manually or with [CocoaPods](http://www.cocoapods.org)

* Manual Configuration
* Download the [Webcom](https://ios.webcom.orange-labs.fr/latest/webcom-ios.zip) framework.
* Copy the framework in your project.
* Add the framework dependency to project's target.

* Cocoapods setup
* Add Webcom to your project's Podfile
```Podfile
target :MyProject do
pod 'Webcom'
end
```

#### Start coding

* Include Webcom header in your app :
```objective-c
#import <Webcom/Webcom.h>
```
```swift
import Webcom
```

* Create a reference to your Flexible Datasync database.
```objective-c
/// Webcom reference
WCWebcom * webcomRef = [[WCWebcom alloc] initWithURL:@"https://io.datasync.orange.com/base/{your-webcom-app}"];
```
```swift
/// Webcom reference
let webcomRef = webcom = WCWebcom(URL: "https://io.datasync.orange.com/base/{your-webcom-app}")
```

* Write data
```objective-c
/// Say Hello
[webcomRef set:@"Hello World!"];
```
```swift
/// Say Hello
webcomRef.set("Hello World!")
```

* Read data
```objective-c
/// Read
[webcomRef onEventType:WCEventTypeValue withCallback:^(WCDataSnapshot * _Nullable snapshot, NSString * _Nullable prevKey)
{
NSString * value = (NSString *)snapshot.value;
NSLog(@"%@", value);
}];
```
```swift
/// Read
webcomRef.onEventType(.Value , withCallback:
{
(snapshot: WCDataSnapshot?, prevKey: String?) -> Void in
if let message = snapshot?.value as? String
{
print(message)
}
}
```

#### More

* See the [API Reference](https://ios.webcom.orange-labs.fr/docs/) for more details.
* Look at the [iOS Demo](https://github.com/webcom-components/webcom-sdk-ios-demo) example.
