//
//  NUPushMessageService.m
//  NextUserKit
//
//  Created by Dino on 3/1/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUPushMessageService.h"

@implementation NUPushMessageService

- (id)initWithSession:(NUTrackerSession *)session
{
    if (self = [super init]) {
        _session = session;
    }
    
    return self;
}

@end
