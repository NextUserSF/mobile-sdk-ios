//
//  NUPushMessage.h
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUIAMUITheme;

@interface NUPushMessage : NSObject

@property (nonatomic) NSString *messageText;
@property (nonatomic) NSURL *contentURL;
@property (nonatomic) NUIAMUITheme *UITheme;
@property (nonatomic) NSDate *fireDate;

@end
