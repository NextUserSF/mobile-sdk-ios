//
//  NUTrackingHTTPRequestHelper.h
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NUTrackingHTTPRequestHelper : NSObject

#pragma mark - Path
+ (NSString *)basePath;
+ (NSString *)pathWithAPIName:(NSString *)APIName;

#pragma mark - Parameters
+ (NSString *)trackActionURLEntryWithName:(NSString *)actionName parameters:(NSArray *)actionParameters;
+ (NSString *)trackActionParametersStringWithActionParameters:(NSArray *)actionParameters;

@end
