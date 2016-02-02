//
//  NUPurchase+Tests.h
//  NextUserKit
//
//  Created by NextUser on 12/10/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <NextUserKit/NextUserKit.h>

@interface NUPurchase (Tests)

+ (NSString *)serializedPurchaseItemStringWithItem:(NUPurchaseItem *)item;
+ (NSString *)serializedPurchaseItemsStringWithItems:(NSArray *)items;
+ (NSString *)serializedPurchaseDetailsStringWithDetails:(NUPurchaseDetails *)purchaseDetails;

@end
