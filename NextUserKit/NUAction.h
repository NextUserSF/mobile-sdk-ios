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

- (void)setFirstParameter:(NSString *)firstParameter;
- (void)setSecondParameter:(NSString *)secondParameter;
- (void)setThirdParameter:(NSString *)thirdParameter;
- (void)setFourthParameter:(NSString *)fourthParameter;
- (void)setFifthParameter:(NSString *)fifthParameter;
- (void)setSixthParameter:(NSString *)sixthParameter;
- (void)setSeventhParameter:(NSString *)seventhParameter;
- (void)setEightParameter:(NSString *)eightParameter;
- (void)setNinthParameter:(NSString *)ninthParameter;
- (void)setTenthParameter:(NSString *)tenthParameter;

@end
