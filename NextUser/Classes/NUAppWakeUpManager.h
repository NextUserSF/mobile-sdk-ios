//
//  NUAppWakeUpManager.h
//  NextUserKit
//
//  Created by Dino on 3/2/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUAppWakeUpManager;

@protocol NUAppWakeUpManagerDelegate <NSObject>

// when app is woken up in background, we ask OS for more time in background.
// when we finish our task
- (void)appWakeUpManager:(NUAppWakeUpManager *)manager
didWakeUpAppInBackgroundWithTaskCompletion:(void(^)())completion;

@end

@interface NUAppWakeUpManager : NSObject

+ (instancetype)manager;

@property (nonatomic, weak) id <NUAppWakeUpManagerDelegate> delegate;

@property (nonatomic) BOOL isRunning;
- (void)start;
- (void)stop;

- (void)requestLocationUsageAuthorization;

+ (BOOL)isAppInBackground;
+ (BOOL)appWakeUpAvailable;

@end
