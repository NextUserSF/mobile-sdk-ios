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
+ (NSString *)serializedPurchaseItemStringWithItem:(NUPurchaseItem *)item;
+ (NSString *)serializedPurchaseItemsStringWithItems:(NSArray *)items;
+ (NSString *)serializedPurchaseDetailsStringWithDetails:(NUPurchaseDetails *)purchaseDetails;

@end
