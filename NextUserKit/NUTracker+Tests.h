//
//  NUTracker+Tests.h
//  NextUserKit
//
//  Created by Dino on 11/13/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <NextUserKit/NextUserKit.h>

@interface NUTracker (Tests)

// track screen tests
- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion;

// track action tests
- (void)trackActionWithName:(NSString *)actionName parameters:(NSDictionary *)actionParameters completion:(void(^)(NSError *error))completion;
- (void)trackActions:(NSArray *)actions completion:(void(^)(NSError *error))completion;

// track purchase
- (void)trackPurchaseWithTotalAmount:(double)totalAmount products:(NSArray *)products purchaseDetails:(NUPurchaseDetails *)purchaseDetails completion:(void(^)(NSError *error))completion;

@end
