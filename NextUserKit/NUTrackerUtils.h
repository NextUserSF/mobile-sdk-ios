//
//  NUTrackerUtils.h
//  NextUserKit
//
//  Created by Dino on 11/23/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUPurchaseDetails;
@class NUTrackerSession;

@interface NUTrackerUtils : NSObject

#pragma mark - Track Screen

+ (void)trackScreenWithName:(NSString *)screenName
                  inSession:(NUTrackerSession *)session
                 completion:(void(^)(NSError *error))completion;

#pragma mark - Track Action

+ (void)trackActionWithName:(NSString *)actionName
                 parameters:(NSArray *)actionParameters
                  inSession:(NUTrackerSession *)session
                 completion:(void(^)(NSError *error))completion;

+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName
                               parameters:(NSArray *)actionParameters;

+ (void)trackActions:(NSArray *)actions
           inSession:(NUTrackerSession *)session
          completion:(void(^)(NSError *error))completion;

#pragma mark - Track Purchase

+ (void)trackPurchaseWithTotalAmount:(double)totalAmount
                            products:(NSArray *)products
                     purchaseDetails:(NUPurchaseDetails *)purchaseDetails
                           inSession:(NUTrackerSession *)session
                          completion:(void(^)(NSError *error))completion;

@end
