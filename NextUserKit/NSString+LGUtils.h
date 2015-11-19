//
//  NSString+LGUtils.h
//  Looks Good
//
//  Created by Dino Bartosak on 07/02/15.
//  Copyright (c) 2015 Dino Bartosak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LGUtils)

- (NSString *)MD5String;
- (NSString *)URLEncodedString;

// each emoji is considered to be length of 1
- (NSUInteger)lengthConsideringEmojis;

@end
