//
//  NSString+LGUtils.m
//  Looks Good
//
//  Created by NextUser Bartosak on 07/02/15.
//  Copyright (c) 2015 Dino Bartosak. All rights reserved.
//

#import "NSString+LGUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LGUtils)

- (NSString *)MD5String
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)URLEncodedStringWithIgnoredCharacters:(NSString *)characters
{
    NSString *unescaped = self;
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
    
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:charactersToEscape];
    if (characters) {
        [characterSet removeCharactersInString:characters];
    }
    
    NSCharacterSet *allowedCharacters = [characterSet invertedSet];
    
    NSString *encodedString = [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    
    return encodedString;
}

- (NSString *)URLEncodedString
{
    return [self URLEncodedStringWithIgnoredCharacters:nil];
}

- (NSUInteger)lengthConsideringEmojis
{
    __block NSInteger length = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                length++;
                            }];
    return length;
}

+ (BOOL)lg_isEmptyString:(NSString *)input
{
    return input == nil || input.length == 0;
}

@end
