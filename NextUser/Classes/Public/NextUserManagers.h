#import <Foundation/Foundation.h>
#import "NUTracker.h"
#import "NUPushNotificationsManager.h"
#import "NUCartManager.h"
#import "NUUIDisplayManager.h"

@interface NextUser : NSObject

+ (NUTracker *) tracker;
+ (NUPushNotificationsManager *) notifications;
+ (NUCartManager *) cartManager;
+ (NUUIDisplayManager *) UIDisplayManager;

@end
