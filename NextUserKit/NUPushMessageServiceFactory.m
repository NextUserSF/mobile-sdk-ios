//
//  NUPushMessageServiceFactory.m
//  NextUserKit
//
//  Created by Dino on 3/1/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUPushMessageServiceFactory.h"
#import "NUPubNubClient.h"

@implementation NUPushMessageServiceFactory

+ (NUPushMessageService *)createPushMessageServiceWithSession:(NUTrackerSession *)session
{
    return [[NUPubNubClient alloc] initWithSession:session];
}

@end
