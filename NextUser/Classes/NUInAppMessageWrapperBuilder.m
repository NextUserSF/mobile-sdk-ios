#import "NUInAppMessageWrapperBuilder.h"
#import "NextUserManager.h"
#import "NUSocialShare.h"


@interface InAppMessageWrapperBuilder()
{
    InAppMsgPrepareCompletionBlock completionBlock;
    InAppMsgWrapper* wrapper;
    JSContext *jsContext;
}
@end

@implementation InAppMessageWrapperBuilder



-(instancetype)initWithCompetion: (InAppMsgPrepareCompletionBlock) completion
{
    if (self = [super init]) {
        completionBlock = completion;
    }
    
    return self;
}

- (void) prepare:(InAppMessage* ) message
{
    wrapper = [InAppMsgWrapper initWithMessage: message];
    wrapper.state = PREPARING;
    
    if ([wrapper isContentHTML] == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                self->wrapper.webView = [self createWebView:self->wrapper];
                self->wrapper.webView.UIDelegate = self;
                //self->wrapper.webView.scalesPageToFit = YES;
                self->wrapper.webView.userInteractionEnabled = YES;
                [self->wrapper.webView setTranslatesAutoresizingMaskIntoConstraints: NO];
                [self->wrapper.webView setClipsToBounds:YES];
                self->wrapper.webView.opaque = NO;
                self->wrapper.webView.backgroundColor = [UIColor redColor];
                [self->wrapper.webView loadHTMLString:[[[message body] contentHTML] html] baseURL:nil];
                DDLogVerbose(@"contentHTML: %@", [[[message body] contentHTML] html]);
                wrapper.state = READY;
                completionBlock(wrapper);
            } @catch (NSException *exception) {
                DDLogError(@"UIWebView shouldStartLoadWithRequest exception: %@", exception);
            }
        });
        
        return;
    }
    
    if (wrapper.image == YES) {
        [self setImageProperties:wrapper];
        if (wrapper.imageSize.height != 0 && wrapper.imageSize.width != 0) {
            wrapper.messageImage = [[[NextUserManager sharedInstance] inAppMsgImageManager] fetchImageSync:[wrapper getCover].url toSize:wrapper.imageSize];
            wrapper.state = READY;
            if (wrapper.messageImage == nil) {
                wrapper.state = FAILED;
            }
        }
    }
    
    completionBlock(wrapper);
}

- (void) setImageProperties:(InAppMsgWrapper* ) wrapper
{
    CGFloat width = 0;
    CGFloat height = 0;
    InAppMsgViewSettings* settings = [[[NextUserManager sharedInstance] inAppMsgUIManager] viewSettings];
    switch (wrapper.message.type) {
        case SKINNY:
            width  = [wrapper hasBody] == NO ? settings.skinnyLargeImgWidth : settings.skinnySmallImgWidth;
            height = settings.skinnyViewHeight;
            
            break;
        case MODAL:
            width  = settings.modalViewWidth;
            height = [wrapper isSingleImage] == YES ? settings.modalHeight : settings.modalMediumViewHeight;
            
            break;
        case FULL:
            width  = settings.screenWidth;
            height = [wrapper hasBody] == YES ? settings.fullSmallImageHeight : settings.screenHeight;
            
            break;
        default:
            break;
    }
    wrapper.imageSize = CGSizeMake(width, height);
}

- (WKWebView *) createWebView:(InAppMsgWrapper* ) wrapper
{
    InAppMsgViewSettings* settings = [[[NextUserManager sharedInstance] inAppMsgUIManager] viewSettings];
    switch (wrapper.message.type) {
        case SKINNY:
            
            return [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, settings.skinnyWidth, settings.skinnyHeight)];
        case MODAL:
            
            return [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, settings.modalWidth, settings.modalHeight)];
        case FULL:
            
            return [[WKWebView alloc] initWithFrame: settings.screenFrame];
        default:
            
            return nil;
    }
}

- (BOOL)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (request == nil || request.URL == nil) {
        
        return YES;
    }
    
    @try {
        NSURL *url = request.URL;
        if ([[url scheme] isEqualToString: NU_WEB_VIEW_SCHEME]) {
            NUUrlAuthority authority = [NUWebViewHelper toNUUrlAuthority: url.host];
            NSMutableDictionary *query = [NUWebViewHelper getQueryDictionary:url];
            switch (authority) {
                case CLOSE_AUTHORITY:
                    [self onCloseAction: query];
                    
                    break;
                case CUSTOM_LINK_AUTHORITY:
                    [self onUrlAction:nil fromQueryDictionary:query];
                    
                    break;
                case CUSTOM_EVENT_AUTHORITY:
                    [self onCustomEvent: query];
                    
                    break;
                case UNKNOWN_AUTHORITY:
                default:
                    DDLogVerbose(@"Unknown nextuser url authority.");
                    [self onCloseAction: query];
            }
            
            return NO;
        }
    } @catch(NSException *e) {
        DDLogError(@"UIWebView shouldStartLoadWithRequest exception: %@", [e reason]);
        
        return NO;
    } @catch(NSError *e) {
        DDLogError(@"UIWebView shouldStartLoadWithRequest error: %@", e);
        
        return NO;
    }
    
    return YES;
}



-(void) onCloseAction:(NSMutableDictionary *) query
{
    InAppMsgClick *click = [self buildClickConfiguration:DISMISS fromQueryDictionary:query];
    [wrapper.interactionListener onInteract: click];
}

-(void) onCustomEvent:(NSMutableDictionary *) query
{
    NUEvent *customEvent = [NUWebViewHelper buildEventFromQueryDictionary:query];
    if (customEvent != nil) {
        [[[NextUserManager sharedInstance] getTracker] trackEvent:customEvent];
    }
}

-(void) onUrlAction:(NSString *) url fromQueryDictionary:(NSMutableDictionary *) query
{
    InAppMsgClick *click = [self buildClickConfiguration:URL fromQueryDictionary:query];
    if (url == nil) {
        url = [NUWebViewHelper extractParameterFromQueryDictionary: query forKey:NU_PARAM_NAME_URL];
    }
    
    if (url == nil) {
         [wrapper.interactionListener onInteract: nil];
        
        return;
    }
    click.value = url;
    [wrapper.interactionListener onInteract: click];
}

-(void) onSocialShareAction:(NSMutableDictionary *) query
{
    NSString *socialNetwork = [NUWebViewHelper extractParameterFromQueryDictionary:query forKey:QUERY_PARAM_SOCIAL_NETWORK];
    NSString *deepLink = [NUWebViewHelper extractParameterFromQueryDictionary:query forKey:QUERY_PARAM_DEEP_LINK];
    if (socialNetwork != nil && deepLink != nil) {
        [self onCustomEvent:query];
        NUSocialShare *socialShareNotifObject = [[NUSocialShare alloc] init];
        socialShareNotifObject.socialNetwork = socialNetwork;
        socialShareNotifObject.deepLink = deepLink;
        [[NextUserManager sharedInstance] sendNextUserLocalNotification:ON_SOCIAL_SHARE withObject:socialShareNotifObject andStatus:YES];
    }

    NUEvent *customEvent = [NUWebViewHelper buildEventFromQueryDictionary:query];
    if (customEvent != nil) {
        [[[NextUserManager sharedInstance] getTracker] trackEvent:customEvent];
    }
}

-(InAppMsgClick *) buildClickConfiguration:(InAppMsgAction) action fromQueryDictionary:(NSMutableDictionary *) query
{
    InAppMsgClick *click = [[InAppMsgClick alloc] init];
    click.action = action;
    NUEvent *customEvent = [NUWebViewHelper buildEventFromQueryDictionary: query];
    if (customEvent != nil) {
        NSMutableArray<NUEvent *> *events = [[NSMutableArray alloc] initWithCapacity:1];
        [events addObject:customEvent];
        click.trackEvents = events;
    }
    
    return click;
}





- (void)webViewDidStartLoad:(WKWebView *)webView
{
    DDLogVerbose(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(WKWebView *)webView
{
    DDLogVerbose(@"webViewDidFinishLoad");
    [self injectNUBridge: webView];
    [self loadJSContext:webView];
    wrapper.state = READY;
    completionBlock(wrapper);
}
- (void)webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogVerbose(@"didFailLoadWithError : %@", error);
    if ([wrapper state] == PREPARING) {
        wrapper.state = FAILED;
        completionBlock(wrapper);
    }
}

- (void) injectNUBridge: (WKWebView *)webView
{
    NSBundle* frameworkBundle = [NSBundle bundleForClass: [NextUserManager class]];
    NSString *path = [frameworkBundle pathForResource:NEXTUSER_JS_BRIDGE ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    InAppMsgContentHtml *contentHTML = wrapper.message.body.contentHTML;
    if (contentHTML.css != nil) {
        jsCode = [NSString stringWithFormat:jsCode, contentHTML.css];
    } else {
        jsCode = [NSString stringWithFormat:jsCode, @""];
    }
    
    WKUserScript *jsScript =[[WKUserScript alloc] initWithSource:jsCode injectionTime:(WKUserScriptInjectionTimeAtDocumentEnd)
                                                forMainFrameOnly:YES];
    [webView.configuration.userContentController addUserScript:jsScript];
}

-(void) loadJSContext: (WKWebView *)webView
{
    jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jsContext[@"nu_ios"] = self;
}

-(void)trackEvent: (NSString*) eventString;
{
    DDLogVerbose(@"UIWebview Track Event called with params : %@", eventString);
    NSArray *eventArr = [eventString componentsSeparatedByString:@","];
    if ([eventArr count] > 0) {
        NSMutableArray *paramsArr = [[NSMutableArray alloc] init];
        for (int i = 1; i < [eventArr count]; i++) {
            [paramsArr addObject:eventArr[i]];
        }
        NUEvent *event = [NUEvent eventWithName:eventArr.firstObject andParameters:paramsArr];
        [[[NextUserManager sharedInstance] getTracker] trackEvent:event];
    }
    
}


- (void)sendData:(NSString *)dataObject withEvent:(NSString *)event withParams:(NSArray *)params {
    
}

- (void)trackEvent:(NSString *)event withParams:(NSArray *)params {
    
}

- (void)triggerClose:(NSString *)dataObject withEvent:(NSString *)event withParams:(NSArray *)params {
    
}

- (void)triggerReload:(NSString *)url withEvent:(NSString *)event withParams:(NSArray *)params {

}

@end
