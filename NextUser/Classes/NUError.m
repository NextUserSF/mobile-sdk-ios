#import "NUError.h"

NSString * const NUNextUserErrorDomain = @"com.nextuser.base";

NSInteger const NUNextUserErrorCodeGeneral = 0;

@implementation NUError

+ (NSError *)nextUserErrorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:NUNextUserErrorDomain
                               code:NUNextUserErrorCodeGeneral
                           userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
