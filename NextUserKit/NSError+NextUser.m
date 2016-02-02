//
//  NSError+NextUser.m
//  NextUserKit
//
//  Created by NextUser on 1/18/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NSError+NextUser.h"
#import "NUErrorDefinitions.h"

NSString * const NUNextUserErrorDomain = @"com.nextuser.base";

NSInteger const NUNextUserErrorCodeGeneral = 0;

@implementation NSError (NextUser)

+ (NSError *)nextUserErrorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:NUNextUserErrorDomain
                               code:NUNextUserErrorCodeGeneral
                           userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
