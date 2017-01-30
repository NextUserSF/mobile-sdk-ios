# Installation

NextUser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NextUser", '~> 0.1.9'
```

You also need to add this into the Podfile:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Dino4674/NUPodSpecsTestPod.git'
```

# Setup
Import *NextUserKit* into the file where you will be using it: 

```objective-c
#import <NextUserKit/NextUserKit.h>
```

or depending if you are using frameworks:

```objective-c
@import NextUser;
```

The main object you are interested in is the *NUTracker* singleton object. To get a reference to it, use singleton getter:

```objective-c
NUTracker *tracker = [NUTracker sharedTracker];
```
## Session startup
For *NUTracker* object to become useful, you need to start its session first. To start a session, call: *-startSessionWithTrackIdentifier:* method:

```objective-c
[tracker startSessionWithTrackIdentifier:@"my_identifier"];
```
... or you can call another version of this method which receives an optional *completion* parameter:

```objective-c
[tracker startSessionWithTrackIdentifier:@"my_identifier" completion:^(NSError *error) {
    // check error object here
}];
```
*completion* parameter is optional here but if you want to know if setup went smoothly, you can check if *error* object is *nil*. 

Start session once on the application startup by calling one of the above methods.

## Logging
*NUTracker* can be setup to log things in 4 different levels: *ERROR*, *WARNING*, *INFO*, *VERBOSE* or it can be turned off completely. Here is an example of how to set *NUTracker*'s logging level to *VERBOSE*:

```objective-c
tracker.logLevel = NULogLevelVerbose;
```

# Usage
## User identify 
You can associate each request with some user identifier. For example, if your application has some logged in user, you can use its identifier (username, email). Do this by calling:

```objective-c
[tracker identifyUserWithIdentifier:@"username@domain.com"];
```
It is enough to call this once.

## Screen tracking
When you want to track a screen view inside your application, use this method:

```objective-c
[tracker trackScreenWithName:@"my_screen_name"];
```
## Action tracking
If you need to track an action (event), use these two methods: 

```objective-c
[tracker trackAction:action];
[tracker trackActions:@[action1, action2]];
```

Both of these two methods are receiving *NUAction* as a parameter (single action or multiple actions inside of *NSArray*). Here is an example of how to create an *NUAction* object using the *NUAction*'s factory method:

```objective-c
NUAction *action = [NUAction actionWithName:@"action_name"];
```

Optionally you can add up to 10 parameters to each action:

```objective-c
[action setSecondParameter:@"2nd_parameter_value"];
[action setTenthParameter:@"10th_parameter_value"];
```

## Purchase tracking
For purchase tracking use these two methods: 

```objective-c
[tracker trackPurchase:purchase];
[tracker trackPurchases:@[purchase1, purchase2]];
```

Both of these two methods are receiving *NUPurchase* as a parameter (single purchase or multiple purchases inside of *NSArray*). Here is an example of how to create an *NUPurchase* object using two *NUPurchase*'s factory methods:

```objective-c
// first create a purchase item (one or more)
NUPurchaseItem *item1 = [NUPurchaseItem itemWithProductName:@"Lord Of The Rings" SKU:@"234523333344"];
item1.category = @"Science Fiction";
item1.productDescription = @"A long book about rings";
item1.price = 99.23;
item1.quantity = 7;

// then optionally create a purchase details object
NUPurchaseDetails *details = [NUPurchaseDetails details];
details.discount = 45.65;
details.shipping = 34.87;
details.state = @"Neverland";
details.city = @"Nevercity";
details.zip = @"NVL 5000";

// we have everything to create our NUPurchase object now

// 1. create purchase with details
NUPurchase *purchase = [NUPurchase purchaseWithTotalAmount:78.97 items:@[item1] details:details];

// 2. create purchase without details
NUPurchase *purchase = [NUPurchase purchaseWithTotalAmount:78.97 items:@[item1]];
```

## Author

Next User, m@nextuser.com

## License

NextUser is available under the MIT license. See the LICENSE file for more info.