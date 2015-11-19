//
//  NUTrackingHTTPRequestHelper.h
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUProduct;
@class NUPurchaseDetails;

@interface NUTrackingHTTPRequestHelper : NSObject

#pragma mark - Path
+ (NSString *)basePath;
+ (NSString *)pathWithAPIName:(NSString *)APIName;

#pragma mark - Parameters
+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName parameters:(NSArray *)actionParameters;
+ (NSString *)trackActionParametersStringWithActionParameters:(NSArray *)actionParameters;
#pragma mark -
+ (NSString *)trackPurchaseParametersStringWithTotalAmount:(double)totalAmount products:(NSArray *)products purchaseDetails:(NUPurchaseDetails *)purchaseDetails;
+ (NSString *)serializedProducts:(NSArray *)products;
+ (NSString *)serializedProduct:(NUProduct *)product;
+ (NSString *)serializedPurchaseDetails:(NUPurchaseDetails *)purchaseDetails;

@end
