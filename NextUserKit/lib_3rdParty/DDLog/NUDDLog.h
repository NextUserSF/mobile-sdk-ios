//
//  NUDDLog.h
//  NextUserKit
//
//  Created by Dino on 11/16/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "CocoaLumberjack.h"

extern DDLogLevel ddLogLevel;

@interface NUDDLog : NSObject

+ (void)setLogLevel:(DDLogLevel)logLevel;
+ (DDLogLevel)logLevel;

@end
