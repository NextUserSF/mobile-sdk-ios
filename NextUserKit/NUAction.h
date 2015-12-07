//
//  NUAction.h
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUAction : NSObject

+ (NUAction *)actionWithName:(NSString *)actionName;

@property (nonatomic, readonly) NSString *actionName;
@property (nonatomic, readonly) NSArray *parameters;

@property (nonatomic) NSString *firstParameter;
@property (nonatomic) NSString *secondParameter;
@property (nonatomic) NSString *thirdParameter;
@property (nonatomic) NSString *fourthParameter;
@property (nonatomic) NSString *fifthParameter;
@property (nonatomic) NSString *sixthParameter;
@property (nonatomic) NSString *seventhParameter;
@property (nonatomic) NSString *eightParameter;
@property (nonatomic) NSString *ninthParameter;
@property (nonatomic) NSString *tenthParameter;

@end
