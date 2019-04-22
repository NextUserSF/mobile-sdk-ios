#import <Foundation/Foundation.h>
#import "NUInternalTracker.h"
#import "NUEvent+Serialization.h"
#import "NUError.h"
#import "NextUserManager.h"

@implementation InternalEventTracker

+(void) trackEvent:(NSString *) eventName withParams:(NSString*) paramsAsString
{
    NSArray *params = [paramsAsString componentsSeparatedByString:@","];
    if (params != nil && [params count] > 10) {
        NSError* error = [NUError nextUserErrorWithMessage: @"invalid params string provided"];
        @throw error;
    }
    
    [[[NextUserManager sharedInstance] getTracker]
            trackEvent: [NUEvent eventWithName:eventName andParameters:[params mutableCopy]]];
}



@end
