#import <Foundation/Foundation.h>
#import "NUUser.h"
#import "NUSubscriberDevice.h"
#import "NUTrackerSession.h"
#import "NUTask.h"
#import "NURegistrationToken.h"
#import "NUCart.h"
#import "NUConstants.h"

@interface NUTrackingHTTPRequestHelper : NSObject

+(NSMutableDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName;
+(NSMutableDictionary *)trackEventsParametersWithEvents:(NSArray *)actions;
+(NSMutableDictionary *)trackCartParametersWithCart:(NUCart *)cart;
+(NSMutableDictionary *)trackUserParametersWithVariables:(NUUser *)user;
+(NSMutableDictionary *)trackUserVariables:(NUUserVariables *)userVariables;
+(NSMutableDictionary *)sessionInitializationParameters:(NUTrackerSession*) session;
+(NSDictionary *)appendSessionDefaultParameters:(NUTrackerSession*) session withTrackParameters:(NSMutableDictionary*) parameters;
+(NSMutableDictionary *)trackUserDeviceParametersWithVariables:(NUSubscriberDevice *)userDevice;
+(NSString *) generateTid:(NUTrackerSession *) session;
+(NSMutableDictionary *) generateCollectDictionary:(NUTaskType) type withObject:(id) trackObject withSession:(NUTrackerSession *) session;
+(NSMutableDictionary *) generateDeviceTokenDictionary:(NURegistrationToken *) deviceToken;
+(NSMutableDictionary *) generateCheckEventDictionary: (id) trackObject withSession:(NUTrackerSession *) session;

@end
