//
//  NUTrackerUtils+Tests.h
//  NextUserKit
//
//  Created by Dino on 11/23/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackerUtils.h"

@class NUTrackerSession;

@interface NUTrackerUtils (Tests)

+ (NSString *)trackIdentifierParameterForSession:(NUTrackerSession *)session;

@end
