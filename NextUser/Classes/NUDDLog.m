#import "NUDDLog.h"

DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation NUDDLog

+ (void)setLogLevel:(DDLogLevel)logLevel
{
    ddLogLevel = logLevel;
}

+ (DDLogLevel)logLevel
{
    return ddLogLevel;
}

@end
