#import <Foundation/Foundation.h>

@interface NUObjectPropertyStatusUtils : NSObject

+ (double)doubleNonSetValue;
+ (BOOL)isDoubleValueSet:(double)doubleValue;

+ (NSUInteger)unsignedIntegerNonSetValue;
+ (BOOL)isUnsignedIntegerValueSet:(double)doubleValue;

+ (BOOL)isStringValueSet:(NSString *)stringValue;
+ (NSString *)toURLEncodedString:(NSString *)toEncode;

@end
