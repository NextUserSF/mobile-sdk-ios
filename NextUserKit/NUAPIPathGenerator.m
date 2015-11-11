//
//  NUAPIPathGenerator.m
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUAPIPathGenerator.h"

#define END_POINT_DEV @"https://track-dev.nextuser.com"
#define END_POINT_PROD @"https://track.nextuser.com"

@implementation NUAPIPathGenerator

+ (NSString *)basePath
{
    return END_POINT_DEV;
}

+ (NSString *)pathWithAPIName:(NSString *)APIName
{
    return [[self basePath] stringByAppendingFormat:@"/%@", APIName];
}

@end
