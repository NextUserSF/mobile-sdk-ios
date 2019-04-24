#import <Foundation/Foundation.h>
#import "NextUser.h"
#import "NextUserManager.h"

@implementation NextUser

+ (NUTracker *) tracker
{
    return [[NextUserManager sharedInstance] getTracker];
}

+ (NUPushNotificationsManager *) notifications
{
    return [[NextUserManager sharedInstance] notificationsManager];
}

+ (NUCartManager *) cartManager
{
    return [[NextUserManager sharedInstance] cartManager];
}

@end
