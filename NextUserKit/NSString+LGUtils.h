//
//  NSString+LGUtils.h
//  Looks Good
//
//  Created by NextUser Bartosak on 07/02/15.
//  Copyright (c) 2015 Dino Bartosak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LGUtils)

- (NSString *)MD5String;
- (NSString *)URLEncodedStringWithIgnoredCharacters:(NSString *)characters;
- (NSString *)URLEncodedString;

// each emoji is considered to be length of 1
- (NSUInteger)lengthConsideringEmojis;

+ (BOOL)lg_isEmptyString:(NSString *)input;

@end
