//
//  NUWebViewSettings.h
//  Pods
//
//  Created by Adrian Lazea on 06.07.2021.
//

#ifndef NUWebViewSettings_h
#define NUWebViewSettings_h
#import <WebKit/WebKit.h>
#import "NUCustomJSCode.h"


@interface NUWebViewSettings : NSObject

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *firstLoadJs;
@property (nonatomic) BOOL enableNavigation;


@property (nonatomic) BOOL overrideOnLoading;
@property (nonatomic) BOOL dimmedBackgroundSpinner;
@property (nonatomic) NSString *spinnerMessage;

@property (nonatomic) BOOL suppressBrowserJSAlerts;
@property NSDictionary<NSString *, NSString *> *httpHeadersExtra;
@property NSArray<NUCustomJSCode *> *customJSCodes;

@end

@protocol NUWebViewUIDelegate <NSObject>
- (void)webViewContainer:(UIView *)view didStartLoadingURL:(NSURL *)URL;
- (void)webViewContainer:(UIView *)view didFinishLoadingURL:(NSURL *)URL;
- (void)webViewContainer:(UIView *)view didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
- (void)onWebViewPageLoadingProgress: (double) progress;
- (void)onWebViewData:(NSDictionary *) dataObject;
- (void)onWebViewClose:(NSDictionary*) dataObject;
@end


#endif /* NUWebViewSettings_h */
