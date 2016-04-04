//
//  NUInAppMessageView.m
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUIAMNotificationView.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"

@interface NUIAMNotificationView ()

@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (nonatomic) UIView *nibMasterView;
@property (weak, nonatomic) IBOutlet UIView *dragView;

@end

@implementation NUIAMNotificationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        UIView *viewFromNib = [[frameworkBundle loadNibNamed:@"NUIAMNotificationView" owner:self options:nil] firstObject];
        viewFromNib.frame = self.bounds;
        
        [self addSubview:viewFromNib];
        
        _nibMasterView = viewFromNib;
        
        [self styleDragView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
    
    return self;
}

- (void)styleDragView
{
    _dragView.layer.cornerRadius = _dragView.bounds.size.height/2.0;
}

#pragma mark - Public

- (void)setMessage:(NUPushMessage *)message
{
    _message = message;
    
    _messageTextLabel.text = message.messageText;
    
    if (message.UITheme.backgroundColor) {
        _nibMasterView.backgroundColor = message.UITheme.backgroundColor;
    }
    if (message.UITheme.textColor) {
        _messageTextLabel.textColor = message.UITheme.textColor;
    }
    if (message.UITheme.textFont) {
        _messageTextLabel.font = message.UITheme.textFont;
    }
}

#pragma mark - Gesture Recognizer

- (void)tap:(UITapGestureRecognizer *)sender
{
    [_delegate IAMNotificationView:self didTapWithRecognizer:sender];
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    [_delegate IAMNotificationView:self didPanWithRecognizer:sender];
}

@end
