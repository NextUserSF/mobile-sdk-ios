
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

#define kIAMContentViewSideInset 5
#define kIAMContentViewCornerRadius 5

@interface NUIAMContentView () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation NUIAMContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        UIView *viewFromNib = [[frameworkBundle loadNibNamed:@"NUIAMContentView" owner:self options:nil] firstObject];
        viewFromNib.frame = self.bounds;
        
        [self addSubview:viewFromNib];
        
        CGRect webViewFrame = CGRectInset(_backgroundView.bounds, kIAMContentViewSideInset, kIAMContentViewSideInset);
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
    NSLog(@"webView fail: %@", error);
}

#pragma mark - Public

- (void)setMessage:(NUPushMessage *)message
{
    _message = message;
    
    if (message.UITheme.backgroundColor) {
        _backgroundView.backgroundColor = message.UITheme.backgroundColor;
        _dismissButton.tintColor = message.UITheme.backgroundColor;
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:message.contentURL
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:30];
    [_webView loadRequest:request];
}

@end
