//
//  NUDDLog.m
//  NextUserKit
//
//  Created by NextUser on 11/16/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

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
