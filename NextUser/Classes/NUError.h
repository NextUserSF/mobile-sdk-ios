//
//  NSError+NextUser.h
//  NextUserKit
//
//  Created by NextUser on 1/18/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const NUNextUserErrorDomain;
extern NSInteger const NUNextUserErrorCodeGeneral;

@interface NUError : NSObject

+ (NSError *)nextUserErrorWithMessage:(NSString *)message;

@end
