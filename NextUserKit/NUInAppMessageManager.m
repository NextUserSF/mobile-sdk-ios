//
//  NUInAppMessageManager.m
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUInAppMessageManager.h"
#import "NUPushMessage.h"
#import "NUInAppMessageView.h"

@interface NUInAppMessageManager ()

@property (nonatomic) NUPushMessage *currentPresentedIAM;

@end

@implementation NUInAppMessageManager

+ (instancetype)sharedManager
{
    static NUInAppMessageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NUInAppMessageManager alloc] init];
    });
    
    return instance;
}

- (void)showPushMessageAsInAppMessage:(NUPushMessage *)message
{
    if (_currentPresentedIAM) {
        // remove _currentPresentedIAM
    }
    
    _currentPresentedIAM = message;
    
    NUInAppMessageView *IAM = [NUInAppMessageView viewForMessage:_currentPresentedIAM withMaxSize:CGSizeMake(300, 100)];
    
    UIView *view = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    [view addSubview:IAM];
}

@end
