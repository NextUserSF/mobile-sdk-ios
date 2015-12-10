//
//  NUPurchaseItem.h
//  NextUserKit
//
//  Created by Dino on 11/18/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUPurchaseItem : NSObject

+ (instancetype)itemWithName:(NSString *)name;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic) NSString *SKU;
@property (nonatomic) NSString *category;
@property (nonatomic) double price;
@property (nonatomic) NSUInteger quantity; // defaults to 1
@property (nonatomic) NSString *itemDescription;

@end
