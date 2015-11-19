//
//  NUPurchaseDetails.h
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUPurchaseDetails : NSObject

+ (instancetype)details;

@property (nonatomic) double discount;
@property (nonatomic) double shipping;
@property (nonatomic) double tax;
@property (nonatomic) NSString *currency;

@property (nonatomic) BOOL incomplete;
@property (nonatomic) NSString *paymentMethod;
@property (nonatomic) NSString *affilation;

@property (nonatomic) NSString *state;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *zip;

@end


//discount - amount of discount, serialized as decimal number with dot: 123.99
//shipping - shipping cost, serialized as number with dot 432.33
//tax - tax, serialized as number with dot 432.33
//currency - string
//incomplete - purchase not completed (failed, saved for later...), serialized as 1 or 0
//method - string, method of payment
//state - string, state (or country) entered on purchase
//city - string
//zip - string, zipcode
//affiliation - string, site's purchase ID or similar