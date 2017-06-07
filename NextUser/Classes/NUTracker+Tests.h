//
//  NUTracker+Tests.h
//  NextUserKit
//
//  Created by NextUser on 11/13/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTracker.h"
#import "NextUserManager.h"

@class NUTrackerSession;

@interface Tracker (Tests)

+ (void)releaseSharedInstance;

- (NUTrackerSession *)session;
- (NextUserManager *)nextUserManager;

@end
