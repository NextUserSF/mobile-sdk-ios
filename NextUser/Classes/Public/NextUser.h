#import <Foundation/Foundation.h>
#import "NUTracker.h"
#import "NUPushNotificationsManager.h"
#import "NUCartManager.h"

@interface NextUser : NSObject

+ (NUTracker *) tracker;
+ (NUPushNotificationsManager *) notifications;
+ (NUCartManager *) cartManager;

@end
