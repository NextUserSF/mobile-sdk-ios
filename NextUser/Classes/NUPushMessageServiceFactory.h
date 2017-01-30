//
//  NUPushMessageServiceFactory.h
//  NextUserKit
//
//  Created by Dino on 3/1/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUPushMessageService.h"

@class NUTrackerSession;

@interface NUPushMessageServiceFactory : NSObject

+ (NUPushMessageService *)createPushMessageServiceWithSession:(NUTrackerSession *)session;

@end
