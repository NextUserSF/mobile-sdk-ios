//
//  NUInAppMessageManager.h
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPushMessage;

@interface NUInAppMessageManager : NSObject

+ (instancetype)sharedManager;

- (void)showPushMessage:(NUPushMessage *)message skipNotificationUI:(BOOL)skipNotificationUI;

@end
