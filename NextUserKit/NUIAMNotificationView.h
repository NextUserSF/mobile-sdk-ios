//
//  NUInAppMessageView.h
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NUPushMessage;
@class NUIAMNotificationView;

@protocol NUIAMNotificationViewDelegate <NSObject>

- (void)IAMNotificationView:(NUIAMNotificationView *)view didTapWithRecognizer:(UITapGestureRecognizer *)gesture;
- (void)IAMNotificationView:(NUIAMNotificationView *)view didPanWithRecognizer:(UIPanGestureRecognizer *)gesture;

@end

@interface NUIAMNotificationView : UIView

@property (nonatomic, weak) id <NUIAMNotificationViewDelegate> delegate;
@property (nonatomic) NUPushMessage *message;

@end
