//
//  NUInAppMessageView.h
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NUPushMessage;

@interface NUInAppMessageView : UIView

+ (NUInAppMessageView *)viewForMessage:(NUPushMessage *)message withMaxSize:(CGSize)maxSize;

@end
