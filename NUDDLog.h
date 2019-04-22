#import "CocoaLumberjack.h"

extern DDLogLevel ddLogLevel;

@interface NUDDLog : NSObject

+ (void)setLogLevel:(DDLogLevel)logLevel;
+ (DDLogLevel)logLevel;

@end
