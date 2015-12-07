//
//  NUTrackingHTTPRequestHelper+Tests.h
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUTrackingHTTPRequestHelper.h"

@class NUAction;

@interface NUTrackingHTTPRequestHelper (Tests)

+ (NSString *)serializedActionStringFromAction:(NUAction *)action;
+ (NSString *)serializedPurchaseStringWithPurchase:(NUPurchase *)purchase;
+ (NSString *)serializedProductStringWithProduct:(NUProduct *)product;
+ (NSString *)serializedProductsStringWithProducts:(NSArray *)products;
+ (NSString *)serializedPurchaseDetailsStringWithDetails:(NUPurchaseDetails *)purchaseDetails;

@end
