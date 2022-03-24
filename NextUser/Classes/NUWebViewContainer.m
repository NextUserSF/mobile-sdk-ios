#import <Foundation/Foundation.h>
#import "NUWebViewContainer.h"
#import "NextUserManager.h"
#import "NUDDLog.h"
#import "NUProgressDialog.h"
#import "NUObjectPropertyStatusUtils.h"

#define    TOOLBAR_HEIGHT 44.0

static void *NUWebViewContext = &NUWebViewContext;

@interface NUWebViewContainer()
{
    BOOL webViewFirstLoad;
    id<NUWebViewContainerListener> containerListener;
    NUProgressDialog *progressDialog;
    UISwipeGestureRecognizer *swipeRightGestureRecognizer;
    NSArray<WKBackForwardListItem *> *firstLoadBackItems;
}

@end

@implementation NUWebViewContainer

+(instancetype)initWithSettings:(NUWebViewSettings *) settings observerDelegate: (id<NUWebViewUIDelegate>) delegate withViewSettings:(InAppMsgViewSettings *) viewSettings withContainerListener: (id<NUWebViewContainerListener>) listener
{
    NUWebViewContainer *instance = [[NUWebViewContainer alloc] init];
    if (instance) {
        instance->webViewFirstLoad = YES;
        instance->_webViewSettings = settings;
        instance->_delegate = delegate;
        instance->containerListener = listener;
        [instance build:viewSettings];
        instance.backgroundColor = [UIColor clearColor];
        
        if (settings.enableNavigationToolbar == YES) {
            UIBarButtonItem* flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
            UIBarButtonItem* fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            fixedSpaceButton.width = 20;
            
            
            if (settings.hideCloseButton == NO) {
                if ([NUObjectPropertyStatusUtils isStringValueSet:settings.closeButtonCaption]) {
                    instance.closeButton = [[UIBarButtonItem alloc] initWithTitle:settings.closeButtonCaption style:UIBarButtonItemStyleDone target:instance action:@selector(close)];
                } else {
                    instance.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                         target:instance action:@selector(close)];
                }
                if ([NUObjectPropertyStatusUtils isStringValueSet:settings.closeButtonColor]) {
                    instance.closeButton.tintColor = [instance colorFromHexString:settings.closeButtonColor];
                }
                
                instance.closeButton.enabled = YES;
            }
            
            if (settings.hideNavigationButtons == NO) {
                NSString* frontArrowString = NSLocalizedString(@"►", nil); // create arrow from Unicode char
                instance.forwardButton = [[UIBarButtonItem alloc] initWithTitle:frontArrowString style:UIBarButtonItemStylePlain target:instance action:@selector(goForward:)];
                instance.forwardButton.enabled = YES;
                instance.forwardButton.imageInsets = UIEdgeInsetsZero;

                NSString* backArrowString = NSLocalizedString(@"◄", nil); // create arrow from Unicode char
                instance.backButton = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:instance action:@selector(goBack:)];
                instance.backButton.enabled = YES;
                instance.backButton.imageInsets = UIEdgeInsetsZero;

                if ([NUObjectPropertyStatusUtils isStringValueSet:settings.navigationButtonColor]) {
                    instance.forwardButton.tintColor = [instance colorFromHexString:settings.navigationButtonColor];
                    instance.backButton.tintColor = [instance colorFromHexString:settings.navigationButtonColor];
                }
            }
            
            float toolbarY = viewSettings.screenFrame.size.height - TOOLBAR_HEIGHT - viewSettings.statusBarHeight;
            CGRect toolbarFrame = CGRectMake(0.0, toolbarY, viewSettings.screenFrame.size.width, TOOLBAR_HEIGHT);
            if (instance.closeButton != nil || instance.backButton != nil) {
                instance.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
                instance.toolbar.alpha = 1.000;
                instance.toolbar.autoresizesSubviews = YES;
                instance.toolbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                instance.toolbar.barStyle = UIBarStyleBlackOpaque;
                instance.toolbar.clearsContextBeforeDrawing = NO;
                instance.toolbar.clipsToBounds = NO;
                instance.toolbar.contentMode = UIViewContentModeScaleToFill;
                instance.toolbar.hidden = NO;
                instance.toolbar.multipleTouchEnabled = NO;
                instance.toolbar.opaque = NO;
                instance.toolbar.userInteractionEnabled = YES;
                if ([NUObjectPropertyStatusUtils isStringValueSet:settings.toolbarColor]) {
                    instance.toolbar.barTintColor = [instance colorFromHexString:settings.toolbarColor];
                }
                instance.toolbar.translucent = settings.toolbarTranslucent;
            }
        
            if (instance.toolbar != nil) {
                if (instance.closeButton != nil && instance.backButton != nil) {
                    [instance.toolbar setItems:@[fixedSpaceButton, instance.backButton, flexibleSpaceButton, instance.closeButton, flexibleSpaceButton, instance.forwardButton, fixedSpaceButton]];
                } else if (instance.backButton != nil)  {
                    [instance.toolbar setItems:@[fixedSpaceButton, instance.backButton, flexibleSpaceButton,  flexibleSpaceButton, instance.forwardButton, fixedSpaceButton]];
                } else {
                    [instance.toolbar setItems:@[fixedSpaceButton, flexibleSpaceButton, instance.closeButton, flexibleSpaceButton, fixedSpaceButton]];
                }
                [instance.toolbar updateConstraintsIfNeeded];
                [instance.toolbar setNeedsUpdateConstraints];
                instance.toolbar.hidden = YES;
                [instance addSubview:instance.toolbar];
            }
        }
        
        CGRect webViewBounds = viewSettings.screenFrame;
        if (instance.toolbar != nil) {
            webViewBounds = CGRectMake(0.0, 0.0, viewSettings.screenFrame.size.width, viewSettings.screenFrame.size.height - TOOLBAR_HEIGHT - viewSettings.statusBarHeight);
        }
        
        instance.webView = [[WKWebView alloc] initWithFrame:webViewBounds configuration:[instance buildWebViewConfiguration]];
        [instance.webView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
        //[instance.webView setFrame: instance.bounds];
        [instance.webView setNavigationDelegate:instance];
        [instance.webView setUIDelegate:instance];
        instance.webView.allowsBackForwardNavigationGestures=YES;
        [instance.webView setMultipleTouchEnabled:YES];
        [instance.webView setAutoresizesSubviews:YES];
        instance.webView.userInteractionEnabled = YES;
        [instance.webView setClipsToBounds:YES];
        [instance.webView.scrollView setAlwaysBounceVertical:YES];
        instance.webView.clearsContextBeforeDrawing = YES;
        instance.webView.contentMode = UIViewContentModeScaleToFill;
        instance.webView.userInteractionEnabled = YES;
        instance.webView.allowsLinkPreview = NO;
        [instance.webView setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        
        instance.webView.opaque=NO;
        if (settings.enableSwipeNavigation == YES) {
            instance->swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
            [instance->swipeRightGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
            [instance.webView addGestureRecognizer:instance->swipeRightGestureRecognizer];
            instance->swipeRightGestureRecognizer.delegate = instance;
        }
        
        [instance.webView addObserver:instance forKeyPath:NSStringFromSelector(@selector(URL)) options:NSKeyValueObservingOptionNew context:NUWebViewContext];
        [instance.webView addObserver:instance forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NUWebViewContext];
    
        [instance addSubview: instance.webView];
        [instance sendSubviewToBack:instance.webView];
        instance.webView.hidden = YES;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:settings.url]];
        [instance.webView loadRequest:request];
    }
    
    return instance;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void) showProgressDialog
{
    if (self->progressDialog) {
        [self->progressDialog hide:YES];
        self->progressDialog = nil;
    }

    self->progressDialog = nil;
    self->progressDialog = [NUProgressDialog showDialogAddedTo:self animated:YES];
    if ([NUObjectPropertyStatusUtils isStringValueSet:self.webViewSettings.spinnerMessage]) {
        self->progressDialog.labelText = self.webViewSettings.spinnerMessage;
    }
    self->progressDialog.mode = NUProgressDialogModeIndeterminate;
    self->progressDialog.dimBackground = self.webViewSettings.dimmedBackgroundSpinner;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self->swipeRightGestureRecognizer]) {
        [self doSwipeRight:nil];
    }
    
    return YES;
}

-(NUPopUpLayout) getFrameLayout
{
    return NUPopUpLayoutMakeWithMargins(NUPopUpHorizontalLayoutCenter,NUPopUpVerticalLayoutCenter,NUPopUpContentMarginsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0));
}

-(void) build:(InAppMsgViewSettings *) viewSettings
{
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setClipsToBounds:YES];
    NSMutableArray *constraints = [[NSMutableArray<NSLayoutConstraint *> alloc] init];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:viewSettings.screenHeight]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:viewSettings.screenWidth]];
    [NSLayoutConstraint activateConstraints:constraints];
}
        
- (WKWebViewConfiguration *) buildWebViewConfiguration
{
    
    NSString *jsBridge = [self jsScriptFromAssets:NEXTUSER_JS_BRIDGE];
    WKUserScript *jsScript =[[WKUserScript alloc] initWithSource:jsBridge injectionTime:(WKUserScriptInjectionTimeAtDocumentStart)
                                                forMainFrameOnly:NO];
    WKUserContentController *wkUController = [WKUserContentController new];
    [wkUController addScriptMessageHandler:self name:@"NextUserJSLogHandler"];
    [wkUController addScriptMessageHandler:self name:@"nuBridgeSendDataHandler"];
    [wkUController addScriptMessageHandler:self name:@"nuBridgeTriggerReloadHandler"];
    [wkUController addScriptMessageHandler:self name:@"nuBridgeTriggerCloseHandler"];
    [wkUController addScriptMessageHandler:self name:@"nuBridgeTrackEventHandler"];
    [wkUController addUserScript: jsScript];
    WKWebViewConfiguration *wkWebConfig = [WKWebViewConfiguration new];
    wkWebConfig.userContentController = wkUController;
        
    return wkWebConfig;
}

-(NSString*) jsScriptFromAssets:(NSString*) fileName
{
    NSBundle* frameworkBundle = [NSBundle bundleForClass: [NextUserManager class]];
    NSString *path = [frameworkBundle pathForResource:fileName ofType:@"js"];
    
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)buildCustomJS:(BOOL)firstLoad forUrl:(NSString *) url
{
    if (self.webViewSettings == nil || (firstLoad == YES && [url isEqual:self.webViewSettings.url])) {
        
        return nil;
    }
    
    NSString* loadJSCode = @"";
    if (self.webViewSettings.customJSCodes != nil && [self.webViewSettings.customJSCodes count] > 0) {
        for (NUCustomJSCode *nextCustomJSCode in self.webViewSettings.customJSCodes) {
            if (nextCustomJSCode.pageURL == nil) {
                loadJSCode = [loadJSCode stringByAppendingString:@""];
            } else {
                switch (nextCustomJSCode.condition) {
                    case EQUALS:
                        if ([nextCustomJSCode.pageURL isEqual:url]) {
                            loadJSCode = nextCustomJSCode.jsCodeString;
                        }
                        
                        break;
                    case CONTAINS:
                        if ([url containsString:nextCustomJSCode.pageURL]) {
                            loadJSCode = nextCustomJSCode.jsCodeString;
                        }
                        
                        break;
                    case STARTS_WITH:
                        if ([url hasPrefix:nextCustomJSCode.pageURL]) {
                            loadJSCode = nextCustomJSCode.jsCodeString;
                        }
                        
                        break;
                    case ENDS_WITH:
                        if ([url hasSuffix:nextCustomJSCode.pageURL]) {
                            loadJSCode = nextCustomJSCode.jsCodeString;
                        }
                        
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
    return loadJSCode;
}

-(void) injectJSCode:(NSString*) loadJSCode {
    if (loadJSCode != nil && [loadJSCode isEqual:@""] == NO) {
        [self.webView evaluateJavaScript:loadJSCode
                  completionHandler:^(NSString *result, NSError *error) {
            if (error != nil) {
                DDLogError(@"Error on loading custom js code：%@", error.localizedDescription);
                          
                return;
            }
        }];
    }
}

-(void) onCloseAction: (NSDictionary *) closeObj
{
    if([self.delegate respondsToSelector:@selector(onWebViewClose:)]) {
        [self.delegate onWebViewClose: closeObj];
    }
    [containerListener onClose];
    //[self clearWebViewCookies];
    
    if (closeObj != nil) {
        NUEvent * event = [NUWebViewHelper buildEventFromQueryDictionary:closeObj];
        if (event != nil) {
            [[[NextUserManager sharedInstance] getTracker] trackEvent:event];
        }
    }
}

- (void)close
{
    [containerListener onClose];
    //[self clearWebViewCookies];
}

-(void) onReloadAction: (NSDictionary *) query
{
    if (query != nil) {
        NUEvent * event = [NUWebViewHelper buildEventFromQueryDictionary:query];
        if (event != nil) {
            [[[NextUserManager sharedInstance] getTracker] trackEvent:event];
        }
    }
    
    [self.webView reload];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        if([self.delegate respondsToSelector:@selector(onWebViewPageLoadingProgress:)]) {
            [self becomeFirstResponder];
            [self.delegate onWebViewPageLoadingProgress: self.webView.estimatedProgress];
        }
        
        if (self.webViewSettings.overrideOnLoading == NO) {
            if(self.webView.estimatedProgress >= 0.8f) {
                if (self ->webViewFirstLoad == YES) {
                    self->firstLoadBackItems = self.webView.backForwardList.backList;
                }
                if (self->progressDialog != nil) {
                    [self->progressDialog hide:YES];
                    self->progressDialog = nil;
                }
                self->_webView.hidden = NO;
                if (self->_toolbar != nil) {
                    self->_toolbar.hidden = NO;
                }
            } else if (self->progressDialog == nil) {
                [self showProgressDialog];
            } else if ([self->progressDialog isHidden] == YES) {
                [self->progressDialog show:YES];
            }
        } else if(self.webView.estimatedProgress >= 0.8f) {
            if (self ->webViewFirstLoad == YES) {
                self->firstLoadBackItems = self.webView.backForwardList.backList;
            }
            self->_webView.hidden = NO;
            if (self->_toolbar != nil) {
                self->_toolbar.hidden = NO;
            }
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(URL))] && object == self.webView) {
        if ([[self gestureRecognizers] count] < 0) {
            [self onCloseAction:nil];
        }
        if ([[NextUserManager sharedInstance] hasInternetConnection] == NO) {
            if([self.delegate respondsToSelector:@selector(webViewContainer:didFailToLoadURL:error:)]) {
                [self.delegate webViewContainer:self didFailToLoadURL:self.webView.URL error:[NUError nextUserErrorWithMessage:@"No Internet Connection. Closing webview."]];
            }
            [self onCloseAction:nil];
        
            return;
        }
        
        NSURL *newURL = [change valueForKey:@"new"];
        if (newURL != nil && [newURL isKindOfClass:[NSNull class]] == NO) {
            NSString *customJSCode = [self buildCustomJS:self->webViewFirstLoad forUrl:newURL.absoluteString];
            [self injectJSCode:customJSCode];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)doSwipeRight:(id)sender
{
    bool canGoBackDoubleCheck = YES;
    NSArray<WKBackForwardListItem *> *currentBackItems = self.webView.backForwardList.backList;
    if ([self->firstLoadBackItems count] > 0 && [currentBackItems count] == [self->firstLoadBackItems count]) {
        canGoBackDoubleCheck = NO;
    }
    
    if ([self.webView canGoBack] == NO || canGoBackDoubleCheck == NO) {
        [self onCloseAction:nil];
    }
}

- (void)goBack:(id)sender
{
    [self.webView goBack];
}

- (void)goForward:(id)sender
{
    [self.webView goForward];
}

- (UIViewController *)currentTopViewController
{
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController)
    {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)clearWebViewCookies {
    
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSURL* libraryURL = [fileManager URLForDirectory:NSLibraryDirectory
                                          inDomain:NSUserDomainMask
                                 appropriateForURL:NULL
                                            create:NO
                                             error:NULL];
  NSURL* cookiesURL = [libraryURL URLByAppendingPathComponent:@"Cookies"
                                                  isDirectory:YES];
  [fileManager removeItemAtURL:cookiesURL error:nil];
}

#pragma mark - WKScriptMessageHandler Methods
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    
    if ([message.name isEqual:@"NextUserJSLogHandler"]) {
        DDLogVerbose(@"NextUser Javascript Console: %@ ", message.body);
        
        return;
    }
    
    if ([message.name isEqual:@"nuBridgeTriggerReloadHandler"]) {
        [self onReloadAction:message.body];
        
        return;
    }
    
    if ([message.name isEqual:@"nuBridgeTriggerCloseHandler"]) {
        if ( message.body != nil && [message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataObjectDictionary = message.body;
            if ([dataObjectDictionary valueForKey:@"track_event"] != nil) {
                NUEvent * event = [NUWebViewHelper buildEventFromQueryDictionary: [dataObjectDictionary valueForKey:@"track_event"]];
                if (event != nil) {
                    [[[NextUserManager sharedInstance] getTracker] trackEvent:event];
                }
            }
            [self onCloseAction:[dataObjectDictionary valueForKey:@"data"]];
        } else {
            [self onCloseAction:nil];
        }
        
        return;
    }
    
    
    if ([message.name isEqual:@"nuBridgeTrackEventHandler"]) {
        if ( message.body != nil && [message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataObjectDictionary = message.body;
            NUEvent * event = [NUWebViewHelper buildEventFromQueryDictionary: dataObjectDictionary];
            if (event != nil) {
                [[[NextUserManager sharedInstance] getTracker] trackEvent:event];
            }
        }
        
        return;
    }
    
    if ([message.name isEqual:@"nuBridgeSendDataHandler"]) {
        if ( message.body != nil && [message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataObjectDictionary = message.body;
            if ([dataObjectDictionary valueForKey:@"track_event"] != nil) {
                NUEvent * event = [NUWebViewHelper buildEventFromQueryDictionary: [dataObjectDictionary valueForKey:@"track_event"]];
                if (event != nil) {
                    [[[NextUserManager sharedInstance] getTracker] trackEvent:event];
                }
            }
            
            if([self.delegate respondsToSelector:@selector(onWebViewData:)] && [dataObjectDictionary valueForKey:@"data"] != nil) {
                [self.delegate onWebViewData: [dataObjectDictionary valueForKey:@"data"]];
            }
        }
        
        return;
    }
}

#pragma mark - UIWebViewDelegate Methods
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (navigationAction.targetFrame != nil &&
        !navigationAction.targetFrame.mainFrame) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [[NSURL alloc] initWithString: navigationAction.request.URL.absoluteString]];
        [webView loadRequest: request];
        
        return nil;
    }
    return nil;
}

/// JSのalert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if ( self ->_webViewSettings.suppressBrowserJSAlerts == YES) {
        completionHandler();
        
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        completionHandler();
    }]];

    [[self currentTopViewController] presentViewController:alertController animated:YES completion:^{}];
}

/// JSのconfirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler(YES);
}

/// JSのprompt
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    completionHandler(prompt);
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo {
    
    return YES;
}

#pragma mark - WKNavigationDelegate Methods
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSString* urlString = navigationAction.request.URL.absoluteString;
    if ([[url scheme] isEqualToString: NU_WEB_VIEW_SCHEME]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        @try {
                NUUrlAuthority authority = [NUWebViewHelper toNUUrlAuthority: url.host];
                NSMutableDictionary *query = [NUWebViewHelper getQueryDictionary:url];
                switch (authority) {
                    case CLOSE_AUTHORITY:
                        [self onCloseAction: query];
                        
                        break;
                    case RELOAD_AUTHORITY:
                        [self onReloadAction: query];
                        
                        break;
                
                    case UNKNOWN_AUTHORITY:
                        DDLogVerbose(@"Unknown nextuser url authority.");
                        [self onCloseAction: query];
                        
                        break;
                    default:
                        
                        break;
            }
        } @catch(NSException *e) {
            DDLogError(@"WKWebView decidePolicyForNavigationAction exception: %@", [e reason]);
            
        } @catch(NSError *e) {
            DDLogError(@"WKWebView decidePolicyForNavigationAction error: %@", e);
        }
    
        return;
    }
    
    if ([urlString isEqualToString: self.webViewSettings.url] && [self.webViewSettings.httpHeadersExtra count] > 0) {
        NSArray *keys = [self.webViewSettings.httpHeadersExtra allKeys];
        NSString *headerField = [keys objectAtIndex:0];
        NSString *headerValue = [self.webViewSettings.httpHeadersExtra valueForKey:headerField];
        if ([[navigationAction.request valueForHTTPHeaderField:headerField] isEqualToString:headerValue]) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            NSMutableURLRequest * newRequest = [navigationAction.request mutableCopy];
            for (NSString *key in keys) {
                [newRequest setValue:key forHTTPHeaderField:[self.webViewSettings.httpHeadersExtra valueForKey:key]];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
            [webView loadRequest:newRequest];
        }
        
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSInteger statusCode = ((NSHTTPURLResponse *)navigationResponse.response).statusCode;
    if (statusCode != 0 && (statusCode/100 == 4 || statusCode/100 == 5)) {
        if([self.delegate respondsToSelector:@selector(webViewContainer:didFailToLoadURL:error:)]) {
            [self.delegate webViewContainer:self didFailToLoadURL:self.webView.URL error:[NUError nextUserErrorWithMessage:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]]];
            [self onCloseAction:nil];
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if(webView == self.webView) {
        if([self.delegate respondsToSelector:@selector(webViewContainer:didStartLoadingURL:)]) {
            [self.delegate webViewContainer:self didStartLoadingURL:self.webView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if(webView == self.webView) {
        if ([NUObjectPropertyStatusUtils isStringValueSet:self.webViewSettings.firstLoadJs] && self->webViewFirstLoad == YES) {
            [self injectJSCode:self.webViewSettings.firstLoadJs];
        }
        
        if (self->webViewFirstLoad == YES) {
            self->webViewFirstLoad = NO;
            
        }
        
        if([self.delegate respondsToSelector:@selector(webViewContainer:didFinishLoadingURL:)]) {
            [self.delegate webViewContainer:self didFinishLoadingURL:self.webView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if(webView == self.webView) {
        if([self.delegate respondsToSelector:@selector(webViewContainer:didFailToLoadURL:error:)]) {
            [self.delegate webViewContainer:self didFailToLoadURL:self.webView.URL error:error];
        }
    }
    self.isError = YES;
    [self onCloseAction:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if(webView == self.webView) {
        if([self.delegate respondsToSelector:@selector(webViewContainer:didFailToLoadURL:error:)]) {
            [self.delegate webViewContainer:self didFailToLoadURL:self.webView.URL error:error];
        }
    }
    self.isError = YES;
    [self onCloseAction:nil];
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(URL))];
    self.webView = nil;
    self.toolbar = nil;
}

@end
