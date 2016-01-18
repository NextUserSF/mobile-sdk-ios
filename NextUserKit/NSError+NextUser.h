//
//  NSError+NextUser.h
//  NextUserKit
//
//  Created by Dino on 1/18/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (NextUser)

+ (NSError *)nextUserErrorWithMessage:(NSString *)message;

@end
