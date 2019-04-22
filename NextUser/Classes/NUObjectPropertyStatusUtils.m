#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"

@implementation NUObjectPropertyStatusUtils

+ (double)doubleNonSetValue
{
    return DBL_MAX;
}

+ (BOOL)isDoubleValueSet:(double)doubleValue
{
    return doubleValue != [self doubleNonSetValue];
}

+ (NSUInteger)unsignedIntegerNonSetValue
{
    return UINT_MAX;
}

+ (BOOL)isUnsignedIntegerValueSet:(double)unsignedIntegerValue
{
    return unsignedIntegerValue != [self unsignedIntegerNonSetValue];
}

+ (BOOL)isStringValueSet:(NSString *)stringValue
{
    return stringValue != nil;
}

+ (NSString *)toURLEncodedString:(NSString *)toEncode
{
    return [toEncode URLEncodedString];
}

@end
