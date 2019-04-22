#import <Foundation/Foundation.h>
extern NSString * const NUNextUserErrorDomain;
extern NSInteger const NUNextUserErrorCodeGeneral;

@interface NUError : NSObject

+ (NSError *)nextUserErrorWithMessage:(NSString *)message;

@end
