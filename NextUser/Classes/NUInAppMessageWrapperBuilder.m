#import "NUInAppMessageWrapperBuilder.h"
#import "NextUserManager.h"
#import "NUSocialShare.h"

typedef NS_ENUM(NSUInteger, NUUrlAuthority) {
    CLOSE_AUTHORITY = 0,
    CUSTOM_LINK_AUTHORITY,
    SOCIAL_SHARE_AUTHORITY,
    CUSTOM_EVENT_AUTHORITY,
    UNKNOWN_AUTHORITY
};

@interface InAppMessageWrapperBuilder()
{
    InAppMsgPrepareCompletionBlock completionBlock;
    InAppMsgWrapper* wrapper;
    JSContext *jsContext;
}
@end

@implementation InAppMessageWrapperBuilder

NSString * const NEXTUSER_JS_FILE = @"nu_html_in_app_msg_js_component";
NSString * const NU_IN_APP_MSG_SCHEME = @"nextuser";
NSString * const NU_URL_AUTHORITY_CLOSE = @"nuClose";
NSString * const NU_URL_AUTHORITY_CUSTOM_LINK = @"nuCustomLink";
NSString * const NU_URL_AUTHORITY_SOCIAL_SHARE = @"nuSocialShare";
NSString * const NU_URL_AUTHORITY_CUSTOM_EVENT = @"nuCustomEvent";
NSString * const QUERY_PARAM_URL = @"nuUrl";
NSString * const QUERY_PARAM_DEEP_LINK = @"nuDeepLink";
NSString * const QUERY_PARAM_SOCIAL_NETWORK = @"nuSocialNetwork";
NSString * const QUERY_PARAM_EVENT = @"nuEvent";

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
            wrapper.webView = [self createWebView:wrapper];
            wrapper.webView.delegate = self;
            wrapper.webView.scalesPageToFit = YES;
            wrapper.webView.userInteractionEnabled = YES;
            [wrapper.webView setTranslatesAutoresizingMaskIntoConstraints: NO];
            [wrapper.webView setClipsToBounds:YES];
            wrapper.webView.opaque = NO;
            wrapper.webView.backgroundColor = [UIColor redColor];
            [wrapper.webView loadHTMLString:[[[message body] contentHTML] html] baseURL:nil];
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

- (UIWebView *) createWebView:(InAppMsgWrapper* ) wrapper
{
    InAppMsgViewSettings* settings = [[[NextUserManager sharedInstance] inAppMsgUIManager] viewSettings];
    switch (wrapper.message.type) {
        case SKINNY:
            
            return [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, settings.skinnyWidth, settings.skinnyHeight)];
        case MODAL:
            
            return [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, settings.modalWidth, settings.modalHeight)];
        case FULL:
            
            return [[UIWebView alloc] initWithFrame: settings.screenFrame];
        default:
            
            return nil;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (request == nil || request.URL == nil) {
        
        return YES;
    }
    
    @try {
        NSURL *url = request.URL;
        if ([[url scheme] isEqualToString: NU_IN_APP_MSG_SCHEME]) {
            NUUrlAuthority authority = [self toNUUrlAuthority: url.host];
            NSMutableDictionary *query = [self getQueryDictionary:url];
            switch (authority) {
                case CLOSE_AUTHORITY:
                    [self onCloseAction: query];
                    
                    break;
                case CUSTOM_LINK_AUTHORITY:
                    [self onUrlAction:nil fromQueryDictionary:query];
                    
                    break;
                case SOCIAL_SHARE_AUTHORITY:
                    [self onSocialShareAction: query];
                    
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

-(NSMutableDictionary *) getQueryDictionary:(NSURL*) url {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSURLQueryItem *queryItem in [urlComponents queryItems]) {
        if (queryItem.value == nil) {
            continue;
        }
        [queryStrings setObject:queryItem.value forKey:queryItem.name];
    }
    
    return queryStrings;
}

-(void) onCloseAction:(NSMutableDictionary *) query
{
    InAppMsgClick *click = [self buildClickConfiguration:DISMISS fromQueryDictionary:query];
    [wrapper.interactionListener onInteract: click];
}

-(void) onCustomEvent:(NSMutableDictionary *) query
{
    NUEvent *customEvent = [self buildEventFromQueryDictionary:query];
    if (customEvent != nil) {
        [[[NextUserManager sharedInstance] getTracker] trackEvent:customEvent];
    }
}

-(void) onUrlAction:(NSString *) url fromQueryDictionary:(NSMutableDictionary *) query
{
    InAppMsgClick *click = [self buildClickConfiguration:URL fromQueryDictionary:query];
    if (url == nil) {
        url = [self extractParameterFromQueryDictionary: query forKey:QUERY_PARAM_URL];
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
    NSString *socialNetwork = [self extractParameterFromQueryDictionary:query forKey:QUERY_PARAM_SOCIAL_NETWORK];
    NSString *deepLink = [self extractParameterFromQueryDictionary:query forKey:QUERY_PARAM_DEEP_LINK];
    if (socialNetwork != nil && deepLink != nil) {
        [self onCustomEvent:query];
        NUSocialShare *socialShareNotifObject = [[NUSocialShare alloc] init];
        socialShareNotifObject.socialNetwork = socialNetwork;
        socialShareNotifObject.deepLink = deepLink;
        [[NextUserManager sharedInstance] sendNextUserLocalNotification:SOCIAL_SHARE withObject:socialShareNotifObject andStatus:YES];
    }
    
    NUEvent *customEvent = [self buildEventFromQueryDictionary:query];
    if (customEvent != nil) {
        [[[NextUserManager sharedInstance] getTracker] trackEvent:customEvent];
    }
}

-(InAppMsgClick *) buildClickConfiguration:(InAppMsgAction) action fromQueryDictionary:(NSMutableDictionary *) query
{
    InAppMsgClick *click = [[InAppMsgClick alloc] init];
    click.action = action;
    NUEvent *customEvent = [self buildEventFromQueryDictionary: query];
    if (customEvent != nil) {
        NSMutableArray<NUEvent *> *events = [[NSMutableArray alloc] initWithCapacity:1];
        [events addObject:customEvent];
        click.trackEvents = events;
    }
    
    return click;
}

-(NUEvent *) buildEventFromQueryDictionary:(NSMutableDictionary *) query
{
    NSString * customEventStr = [self extractParameterFromQueryDictionary: query forKey:QUERY_PARAM_EVENT];
    if (customEventStr == nil) {
        
        return nil;
    }
    
    NSArray *eventArr = [customEventStr componentsSeparatedByString:@","];
    if (eventArr == nil || eventArr.count <= 0) {
        
        return nil;
    }
    
    if (eventArr.count == 1) {
        
        return [NUEvent eventWithName:[eventArr firstObject]];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    for (int i = 1; i < [eventArr count]; i++) {
        [params addObject:[eventArr objectAtIndex:i]];
    }
    
    return [NUEvent eventWithName:[eventArr firstObject] andParameters:params];
}

-(NSString *) extractParameterFromQueryDictionary:(NSMutableDictionary *) query forKey:(NSString *) key
{
    if (query == nil) {
        
        return nil;
    }
    
    return [query valueForKey:key];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DDLogVerbose(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLogVerbose(@"webViewDidFinishLoad");
    [self injectNUBridge: webView];
    [self loadJSContext:webView];
    wrapper.state = READY;
    completionBlock(wrapper);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogVerbose(@"didFailLoadWithError : %@", error);
    if ([wrapper state] == PREPARING) {
        wrapper.state = FAILED;
        completionBlock(wrapper);
    }
}

- (void) injectNUBridge: (UIWebView *)webView
{
    NSBundle* frameworkBundle = [NSBundle bundleForClass: [NextUserManager class]];
    NSString *path = [frameworkBundle pathForResource:NEXTUSER_JS_FILE ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    InAppMsgContentHtml *contentHTML = wrapper.message.body.contentHTML;
    if (contentHTML.css != nil) {
        jsCode = [NSString stringWithFormat:jsCode, contentHTML.css];
    } else {
        jsCode = [NSString stringWithFormat:jsCode, @""];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:jsCode];
}

-(void) loadJSContext: (UIWebView *)webView
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

-(NUUrlAuthority) toNUUrlAuthority:(NSString*) authority
{
    if ([NU_URL_AUTHORITY_CLOSE isEqualToString:authority]) {
        
        return CLOSE_AUTHORITY;
    } else if ([NU_URL_AUTHORITY_CUSTOM_LINK isEqualToString:authority]) {
        
        return CUSTOM_LINK_AUTHORITY;
    } else if ([NU_URL_AUTHORITY_SOCIAL_SHARE isEqualToString:authority]) {
        
        return SOCIAL_SHARE_AUTHORITY;
    } else if ([NU_URL_AUTHORITY_CUSTOM_EVENT isEqualToString:authority]) {
        
        return CUSTOM_EVENT_AUTHORITY;
    } else {
        
        return UNKNOWN_AUTHORITY;
    }
}

@end
