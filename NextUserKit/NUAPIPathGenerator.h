//
//  NUAPIPathGenerator.h
//  NextUserKit
//
//  Created by Dino on 11/11/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NUAPIPathGenerator : NSObject

+ (NSString *)basePath;
+ (NSString *)pathWithAPIName:(NSString *)APIName;

@end
