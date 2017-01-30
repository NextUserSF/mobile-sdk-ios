//
//  NUTrackingHTTPRequestHelper.h
//  NextUserKit
//
//  Created by NextUser on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUTrackingHTTPRequestHelper : NSObject

#pragma mark - Path
+ (NSString *)basePath;
+ (NSString *)pathWithAPIName:(NSString *)APIName;

#pragma mark - Track Request URL Parameters
+ (NSDictionary *)trackScreenParametersWithScreenName:(NSString *)screenName;
+ (NSDictionary *)trackActionsParametersWithActions:(NSArray *)actions;
+ (NSDictionary *)trackPurchasesParametersWithPurchases:(NSArray *)purchases;

@end
