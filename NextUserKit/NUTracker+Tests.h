//
//  NUTracker+Tests.h
//  NextUserKit
//
//  Created by NextUser on 11/13/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <NextUserKit/NextUserKit.h>
@class NUTrackerSession;
@class NUPrefetchTrackerClient;

@interface NUTracker (Tests)

+ (void)releaseSharedInstance;

- (NUTrackerSession *)session;
- (NUPrefetchTrackerClient *)prefetchClient;

@end
