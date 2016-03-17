//
//  NUInAppMessageContentView.h
//  NextUserKit
//
//  Created by Dino on 3/16/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NUPushMessage;
@class NUIAMContentView;

@protocol NUIAMContentViewDelegate <NSObject>

- (void)IAMContentViewDidDismiss:(NUIAMContentView *)view;

@end

@interface NUIAMContentView : UIView

@property (nonatomic, weak) id <NUIAMContentViewDelegate> delegate;
@property (nonatomic) NUPushMessage *message;

@end
