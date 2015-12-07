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

+ (NUAction *)actionWithName:(NSString *)actionName
              firstParameter:(NSString *)firstParameter
             secondParameter:(NSString *)secondParameter
              thirdParameter:(NSString *)thirdParameter
             fourthParameter:(NSString *)fourthParameter
              fifthParameter:(NSString *)fifthParameter
              sixthParameter:(NSString *)sixthParameter
            seventhParameter:(NSString *)seventhParameter
              eightParameter:(NSString *)eightParameter
              ninthParameter:(NSString *)ninthParameter
              tenthParameter:(NSString *)tenthParameter;

@property (nonatomic, readonly) NSString *actionName;
@property (nonatomic, readonly) NSArray *parameters;

@end
