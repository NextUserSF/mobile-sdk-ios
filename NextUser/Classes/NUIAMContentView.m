
//
//  NUInAppMessageContentView.m
//  NextUserKit
//
//  Created by Dino on 3/16/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUIAMContentView.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"
#import "NURoundedDismissButton.h"
#import "NUDDLog.h"

#define kIAMContentViewSideInset 10
#define kIAMContentViewCornerRadius 4

@interface NUIAMContentView () <UIWebViewDelegate>

#pragma mark - Main Views
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

#pragma mark - Dismiss Button
@property (weak, nonatomic) IBOutlet NURoundedDismissButton *dismissButton;

@end

@implementation NUIAMContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        UIView *viewFromNib = [[frameworkBundle loadNibNamed:@"NUIAMContentView" owner:self options:nil] firstObject];
        viewFromNib.frame = self.bounds;
        
        [self addSubview:viewFromNib];
        
        CGRect webViewFrame = CGRectMake(0,
                                         kIAMContentViewSideInset,
                                         _backgroundView.bounds.size.width,
                                         _backgroundView.bounds.size.height - 2*kIAMContentViewSideInset);
        _webView.frame = webViewFrame;
        
        _backgroundView.layer.cornerRadius = kIAMContentViewCornerRadius;
    }
    
    return self;
}

#pragma mark - Action

- (IBAction)dismissAction:(id)sender
{
    [_delegate IAMContentViewDidDismiss:self];
}

#pragma mark - Web View Delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogError(@"webView fail: %@", error);
}

#pragma mark - Public

- (void)setMessage:(NUPushMessage *)message
{
    _message = message;
    
    if (message.UITheme.backgroundColor) {
        _backgroundView.backgroundColor = message.UITheme.backgroundColor;
        _dismissButton.color = message.UITheme.backgroundColor;
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:message.contentURL
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:30];
    [_webView loadRequest:request];
}

@end
