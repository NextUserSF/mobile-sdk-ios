#import <Foundation/Foundation.h>

@interface InternalEventTracker : NSObject

+(void) trackEvent:(NSString *) eventName withParams:(NSString*) params;

@end

