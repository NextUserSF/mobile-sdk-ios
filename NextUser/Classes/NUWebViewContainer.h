//
//  NUWebViewContainer.h
//  NextUser
//
//  Created by Adrian Lazea on 10.07.2021.
//

#ifndef NUWebViewContainer_h
#define NUWebViewContainer_h


#import <Foundation/Foundation.h>
#import "NUWebViewSettings.h"
#import "NUInAppMsgViewSettings.h"
#import "NUWebViewHelper.h"
#import "NUInAppMessageUIView.h"

@interface NUWebViewContainer : UIView <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,UIGestureRecognizerDelegate>

@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic) NUWebViewSettings *webViewSettings;
@property (nonatomic) id<NUWebViewUIDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* closeButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* forwardButton;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, assign) BOOL isError;

+(instancetype)initWithSettings:(NUWebViewSettings *) settings observerDelegate: (id<NUWebViewUIDelegate>) delegate withViewSettings:(InAppMsgViewSettings *) viewSettings withContainerListener: (id<NUWebViewContainerListener>) listener;
-(NSString*) jsScriptFromAssets:(NSString*) fileName;
-(NUPopUpLayout) getFrameLayout;
-(void)doSwipeRight:(id)sender;
@end


#endif /* NUWebViewContainer_h */


