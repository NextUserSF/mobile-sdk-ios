#import <Foundation/Foundation.h>

#define TRACK_EVENT_DISPLAYED @"_displayed"
#define TRACK_EVENT_CLICKED @"_clicked"
#define TRACK_EVENT_DISMISSED @"_dismissed"
#define TRACK_EVENT_DELIVERD @"_delivered"
#define TRACK_EVENT_PURCHASE_COMPLETED @"purchase_completed"
#define TRACK_EVENT_IOS_SUBSCRIBED @"ios_subscribed"


@interface InternalEventTracker : NSObject

+(void) trackEvent:(NSString *) eventName withParams:(NSString*) params;

@end

