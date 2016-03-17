//
//  NUInAppMessageManager.m
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUInAppMessageManager.h"
#import "NUPushMessage.h"
#import "NUIAMNotificationView.h"
#import "NUIAMContentView.h"
#import "NUIAMUITheme.h"
#import "NUDDLog.h"

#define kIAMNotificationViewSideInset 20
#define kIAMNotificationViewHeight 75
#define kIAMNotificationViewCornerRadius 5

#define kIAMContentViewSideInset 15

@interface NUInAppMessageManager () <NUIAMNotificationViewDelegate, NUIAMContentViewDelegate>

@property (nonatomic) NUIAMNotificationView *notificationView;
@property (nonatomic) UIView *contentViewPlaceholder;
@property (nonatomic) NUIAMContentView *contentView;

@property (nonatomic) NSTimer *notificationViewDismissTimer;
@property (nonatomic) BOOL isIAMNotificationPresented;

@end

@implementation NUInAppMessageManager

#pragma mark - Public

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
    [self showNotificationViewForMessage:message];
}

#pragma mark - Private

- (void)initializeIAMViewsOnce
{
    if (_notificationView == nil) {
        
        // 1. grab the parent view
        UIView *parentView = [self parentView];
        
        // 2. calculate IAM notification view frame
        CGFloat notificationSideInsets = kIAMNotificationViewSideInset;
        CGRect notificationViewFrame = CGRectMake(notificationSideInsets,
                                                  0,
                                                  parentView.bounds.size.width - 2*notificationSideInsets,
                                                  kIAMNotificationViewHeight);
        
        // 3. create IAM notification view
        NUIAMNotificationView *notificationView = [[NUIAMNotificationView alloc] initWithFrame:notificationViewFrame];
        notificationView.delegate = self;
        
        // 4. style IAM notification view with mask (bottom rounded corners)
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:notificationView.bounds
                                         byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                               cornerRadii:CGSizeMake(kIAMNotificationViewCornerRadius, kIAMNotificationViewCornerRadius)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = notificationView.bounds;
        maskLayer.path = maskPath.CGPath;
        notificationView.layer.mask = maskLayer;
        
        // 5. create IAM content view placeholder
        UIView *contentViewPlaceholder = [[UIView alloc] initWithFrame:parentView.bounds];
        
        // 6. calculate IAM content view frame
        CGFloat contentSideInsets = kIAMContentViewSideInset;
        CGRect contentViewFrame = CGRectMake(contentSideInsets,
                                             contentSideInsets,
                                             contentViewPlaceholder.bounds.size.width - 2*contentSideInsets,
                                             contentViewPlaceholder.bounds.size.height - 2*contentSideInsets);
        
        // 7. create IAM content view & add it to its placeholder
        NUIAMContentView *contentView = [[NUIAMContentView alloc] initWithFrame:contentViewFrame];
        contentView.delegate = self;
        [contentViewPlaceholder addSubview:contentView];
        
        // 8. assign values to ivars
        _contentViewPlaceholder = contentViewPlaceholder;
        _contentView = contentView;
        _notificationView = notificationView;
    }
}

- (UIView *)parentView
{
    return [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
}

#pragma mark - IAM Notification Show/Hide

- (void)showNotificationViewForMessage:(NUPushMessage *)message
{
    if (!_isIAMNotificationPresented) {
        
        _isIAMNotificationPresented = YES;
        [self revealIAMNotificationViewForMessage:message withCompletion:^{
            [self scheduleNotificationDismissTimer];
        }];
        
    } else {
        DDLogWarn(@"Already showing IAM!");
    }
}

- (void)dismissNotificationView
{
    [self invalidateNotificationDismissTimer];
    [self unrevealIAMNotificationViewWithCompletion:^{
        _isIAMNotificationPresented = NO;
    }];
}

#pragma mark -

- (void)revealIAMNotificationViewForMessage:(NUPushMessage *)message withCompletion:(void(^)())completion
{
    // 1. create IAM notification & content views
    [self initializeIAMViewsOnce];
    
    _notificationView.transform = CGAffineTransformIdentity;
    _contentViewPlaceholder.transform = CGAffineTransformIdentity;
    
    _notificationView.message = message;
    _contentView.message = message;
    
    // don't forget to apply theme
    _contentViewPlaceholder.backgroundColor = message.UITheme.backgroundColor;
    
    // 2. add views to parent view
    UIView *parentView = [self parentView];
    [parentView addSubview:_notificationView];
    [parentView addSubview:_contentViewPlaceholder];
    
    // 3. hide content view from screen
    CGRect contentViewPlaceholderFrame = CGRectMake(0,
                                                    -_contentViewPlaceholder.bounds.size.height,
                                                    _contentViewPlaceholder.bounds.size.width,
                                                    _contentViewPlaceholder.bounds.size.height);
    _contentViewPlaceholder.frame = contentViewPlaceholderFrame;
    
    // 4. animate notification view from screen top
    CGFloat xOffset = kIAMNotificationViewSideInset;
    CGRect notificationViewEndFrame = CGRectMake(xOffset,
                                                 0,
                                                 _notificationView.bounds.size.width,
                                                 _notificationView.bounds.size.height);
    
    CGRect notificationViewStartFrame = CGRectMake(xOffset,
                                                   -_notificationView.bounds.size.height,
                                                   _notificationView.bounds.size.width,
                                                   _notificationView.bounds.size.height);
    
    _notificationView.frame = notificationViewStartFrame;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         _notificationView.frame = notificationViewEndFrame;
                     } completion:^(BOOL finished) {
                         completion();
                     }];
}

- (void)unrevealIAMNotificationViewWithCompletion:(void(^)())completion
{
    NSAssert(_notificationView != nil, @"notification view can not be nil");
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -_notificationView.bounds.size.height);
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         _notificationView.transform = transform;
                         _contentViewPlaceholder.transform = transform;
                     } completion:^(BOOL finished) {
                         [_notificationView removeFromSuperview];
                         [_contentViewPlaceholder removeFromSuperview];
                         completion();
                     }];
}

#pragma mark - IAM Content Show/Hide

- (void)showContentFully
{
    [self invalidateNotificationDismissTimer];
    
    UIView *parentView = [self parentView];
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, parentView.bounds.size.height);
    CGAffineTransform notificationViewEndTransform = transform;
    CGAffineTransform contentViewEndTransform = transform;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         _notificationView.transform = notificationViewEndTransform;
                         _contentViewPlaceholder.transform = contentViewEndTransform;
                     } completion:nil];
}

- (void)resetIAMViewsOnTouchEnd
{
    CGAffineTransform notificationViewEndTransform = CGAffineTransformIdentity;
    CGAffineTransform contentViewEndTransform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         _notificationView.transform = notificationViewEndTransform;
                         _contentViewPlaceholder.transform = contentViewEndTransform;
                     } completion:^(BOOL finished) {
                         [self scheduleNotificationDismissTimer];
                     }];
}

#pragma mark - Notification Dismiss Timer

- (void)scheduleNotificationDismissTimer
{
    _notificationViewDismissTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                     target:self
                                                                   selector:@selector(notificationDismissTimerFired:)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (void)invalidateNotificationDismissTimer
{
    [_notificationViewDismissTimer invalidate];
    _notificationViewDismissTimer = nil;
}

- (void)notificationDismissTimerFired:(NSTimer *)timer
{
    [self dismissNotificationView];
}

#pragma mark - IAM Content View Delegate

- (void)IAMContentViewDidDismiss:(NUIAMContentView *)view
{
    [self dismissNotificationView];
}

#pragma mark - IAM Notification View Delegate

- (void)IAMNotificationView:(NUIAMNotificationView *)view didTapWithRecognizer:(UITapGestureRecognizer *)gesture
{
    [self showContentFully];
}

- (void)IAMNotificationView:(NUIAMNotificationView *)view didPanWithRecognizer:(UIPanGestureRecognizer *)gesture
{
    UIView *parentView = [self parentView];
    CGPoint translation = [gesture translationInView:parentView];

    switch (gesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            
            [self invalidateNotificationDismissTimer];
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, translation.y);
            _notificationView.transform = transform;
            _contentViewPlaceholder.transform = transform;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
        case UIGestureRecognizerStateRecognized:
        {
            BOOL shouldShowContentViewFully = translation.y >= parentView.bounds.size.height/2.0;
            BOOL shouldUnrevealNotificationView = translation.y < (-_notificationView.bounds.size.height/2.0);
            
            if (shouldShowContentViewFully) {
                [self showContentFully];
            } else if (shouldUnrevealNotificationView) {
                [self dismissNotificationView];
            } else {
                [self resetIAMViewsOnTouchEnd];
            }
        }
            break;
    }
}

@end
